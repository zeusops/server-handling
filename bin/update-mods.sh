#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

usage() {
  (echo "Usage: $(basename $0) servername [--skipdl] [--all] [--keys] [--prompt] [--no-missing] [--check-only] [--notify] [--no-mail] [--no-discord] [-v|--verbose]"
  echo "OPTIONS"
  echo "  --skipdl      Skip all downloads"
  echo "  --all         Redownload all mods"
  echo "  --keys        Install keys automatically"
  echo "  --prompt      Show a confirmation prompt before downloading missing mods"
  echo "  --no-missing  Do not install missing mods"
  echo "  --check-only  Only check for updates, do not download"
  echo "  --notify      Notify admins on mod updates (email, Discord)"
  echo "  --no-mail     Do not send mail on mod updates"
  echo "  --no-discord  Do not send Discord messages on mod updates"
  echo "  -v|--verbose  Enable verbose output") >&2
  exit 1
}

prompt_missing=no
skip_downloads=no
install_keys_automatically=no
force_download=no
install_missing=yes
check_only=no
notify=no
no_mail=no
no_discord=no
verbose=no

argv=()
flags=()
while [ "${1:-}" ]; do
  case "$1" in
  --skipdl)
    skip_downloads=yes
  ;;
  --all)
    force_download=yes
  ;;
  --keys)
    install_keys_automatically=yes
  ;;
  --prompt)
    prompt_missing=yes
  ;;
  --no-missing)
    install_missing=no
  ;;
  --check-only)
    check_only=yes
  ;;
  --notify)
    notify=yes
  ;;
  --no-mail)
    no_mail=yes
  ;;
  --no-discord)
    no_discord=yes
  ;;
  --verbose|-v)
    verbose=yes
  ;;
  --*)
    flags+=("$1")
  ;;
  *)
    argv+=("$1")
  esac
  shift
done
# Restore unprocessed positional arguments
set -- "${argv[@]}"

readonly name=${1:-}; shift || true
if [ -z "$name" ]; then
  usage
fi
# Restore unprocessed flags
set -- "$@" "${flags[@]}"
if [ $# -ne 0 ]; then
  echo "Unknown arguments: $@" >&2
  usage
fi

source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh
readonly mods=$armadir/mods/$name
export updated_keys=$armadir/updated_keys/$name
export available_keys=$armadir/available_keys/$name

readonly mod_list="$mod_lists/$name.txt"
if [ ! -f "$mod_list" ]; then
  echo "Mod list $mod_list not found!" >&2
  exit 2
fi

function symlink {
  OPTIND=1
  verbose=""
  force=""
  while getopts "vf" opt; do
    case "$opt" in
    v)
      verbose="-v"
    ;;
    f)
      force="-f"
    ;;
    esac
  done
  shift $((OPTIND-1))
  # echo "target $target"
  # echo "link_name $link_name"
  # echo "dirname $(dirname $link_name)"
  # echo "win $WINDOWS"
  if [ ${WINDOWS:-no} = "yes" ]; then
    target="$(realpath $1)"
    link_name="$(realpath $2)"
    path=$(realpath --relative-to=$(dirname $link_name) $target)
    echo "path $path"
  else
    path=$1
    link_name=$2
  fi
  ln -s $verbose $force $path $link_name
}

export -f symlink

function link_keys {
  # echo arma $armadir
  # echo "link_keys param $1"
  key_path="$1"
  key_name=$(basename "$key_path")
  # echo "key $key_name"
  if [ ! -f "$available_keys/$key_name" ]; then
    path=$(relpath "$key_path" "$updated_keys")
    #echo path $path
    #symlink -vf $path $updated_keys/$key_name
    ln -svf "$path" "$key_name"
  fi
}

function remove_old_keys {
  echo "Removing old keys"
  # Removes broken symlinks from available_keys/$name
  find $available_keys -type l -exec sh -c 'for x; do [ -e "$x" ] || rm -v "$x"; done' _ {} +
}

function install_keys {
  echo "Installing keys"
  find $updated_keys -name "*.bikey" -type l -exec mv {} $available_keys -v \;
}

function install_mods {
  echo "Installing mods"
  echo "missing $missingid"
  $bin/install-mod-ids.sh $missingid
  pushd $mods > /dev/null
  for mod_id in $missingid; do
    modpath=$mods/$modname
    #moddlpath=$workshop/$mod_id
    #symlink -v $workshop/$mod_id $modpath
    ln -sv ../../workshop/$mod_id $modpath
  done
  popd > /dev/null
}

function relpath {
  if [ -L "$1" ]; then
    target=$(readlink "$1")
  else
    target="$1"
  fi
  dir=${2:-.}
  # >&2 echo all $@
  # >&2 echo relpath $target $dir
  # >&2 echo link $(readlink "$1")
  # exit 1
  echo $(python3 -c "import os; print(os.path.relpath(\"$target\", \"$dir\"))")
}

export -f link_keys
export -f relpath

allmods=""
allmodids=""
allmodids_array=()
missing_name=""
missingid=""

declare -A mod_names
while read line; do
  # Skip line if it starts with a #
  [[ $line =~ ^#.* ]] && continue

  array=($line)
  if ! [ -z $array ]; then
    # File format:
    # @modname 123456
    modname=${array[0]}
    modid=${array[1]}
    modpath=$mods/$modname
    mod_names["$modid"]="$modname"
    if [ $modid -eq 0 ]; then
      echo "Skipping local mod $modname"
      continue
    fi

    allmods="$allmods +workshop_download_item 107410 $modid validate"
    if [ -z "$allmodids" ]
    then
        # Its empty, no space necessary
        allmodids="$modid"
    else
        allmodids="$allmodids $modid"
    fi
    allmodids_array+=("$modid")

    #moddlpath=$workshop/$modid
    if [ ! -e $workshop/$modid ]; then
      # echo $moddlpath
      echo "$modname with ID $modid missing"
      missing_name="$missing_name $modname"
      missingid="$missingid $modid"
    fi
  else
    echo "Found empty modid"
  fi
done < $mod_list

did_update="no"
if [ ! -z "$allmods" -a "$skip_downloads" = "no" ]; then
  # Run the DB update, fetching the current mod update dates from the Workshop
  path_data=$files/data
  mkdir -p $path_data
  update_status=0
  flags=""
  if [ "$install_missing" != "yes" ]; then
    flags="-e ${flags}"
  fi
  if [ "$verbose" = "yes" ]; then
    flags="-v ${flags}"
  fi
  if [ "$notify" = "yes" ]; then
    flags="--notify ${flags}"
  fi
  if [ "$no_mail" = "yes" ]; then
    flags="--no-mail ${flags}"
  fi
  if [ "$no_discord" = "yes" ]; then
    flags="--no-discord ${flags}"
  fi
  $bin/internal/workshop-checker/update_db.sh -c $flags \
      -w "$STEAM_INSTALL_DIR" \
      -s $path_data/versions_local_state_$name.json $allmodids || update_status=$?
  if [ "$update_status" != "0" ] && [ "$update_status" != "4" ]; then
    echo "Failed to check mod update status. Exiting" >&2
    exit "$update_status"
  fi

  if [ "$update_status" = "0" ]; then
    echo "No updates found"
  fi

  if [ "$check_only" = "yes" ]; then
    exit
  fi
  if [ "$force_download" = "yes" ]; then
    echo "Updating all mods (forced)..."
    $bin/install-mod-ids.sh $allmods
    echo
    did_update="yes"
  elif [ "$update_status" = "4" ]; then
    echo "Updating only updated mods..."
    updated_mods=()
    for modid in "${allmodids_array[@]}"
    do
      modname=${mod_names[$modid]}
      echo "Checking mod $modname ($modid)"
      mod_status=0
      $bin/internal/workshop-checker/check_update.sh -s $path_data/versions_local_state_$name.json $modid || mod_status=$?
      if [ "$mod_status" = "1" ]; then
        updated_mods+=("$modid")
        echo "Detected update for mod $modname, running Steam update."
      fi
    done
    # TODO: mail
    $bin/install-mod-ids.sh "${updated_mods[@]}"
    echo
    did_update="yes"
  fi
fi
if [ "$did_update" = "yes" ]; then
  # Run the script from the start without downloading to set up symlinks and keys
  $0 $name --skipdl
  exit
fi

echo "Creating folders"
if [ ! -d $mods ]; then mkdir -p $mods; fi
if [ ! -d $updated_keys ]; then mkdir -p $updated_keys; fi
if [ ! -d $available_keys ]; then mkdir -p $available_keys; fi

echo "Removing old mod links"
find $mods -type l -exec rm {} \;
echo "Removing old key links"
find $updated_keys -type l -exec rm {} \;

if [ "$skip_downloads" = "no" ] && [ ! -z "$missing_name" ]; then
  echo "Missing mods: $missing_name"
  if [ "$install_missing" = "yes" ]; then
    if [ "$prompt_missing" = "no" ]; then
      install_mods
    else
      while :; do
        read -t10 -p "Do you want to install the missing mods to the server automatically? (10 seconds timeout) (Y/n): " || ret=$?
        if [ ${ret:-$?} -gt 128 ]; then
          echo "Timed out waiting for user response"
          REPLY=Y
          break
        fi

        case $REPLY in
          [yY]*|*)
            install_mods
            break
          ;;
          [nN]*)
            echo "Not installing mods"
            break
          ;;
        esac
      done
    fi
  else
    echo "Not installing missing mods"
  fi
fi

pushd $mods > /dev/null
while read line; do
  # Skip line if it starts with a #
  [[ $line =~ ^#.* ]] && continue

  array=($line)
  if ! [ -z $array ]; then
    # File format:
    # @modname 123456
    modname=${array[0]}
    modid=${array[1]}
    modpath=$mods/$modname
    if [ $modid -eq 0 ]; then
      echo "Skipping local mod $modname"
      continue
    fi

    if [ -e $modpath ]; then
      rm $modpath
    fi
    #moddlpath=$workshop/$modid
    #symlink $workshop/$modid $modpath
    if [ -d ../../workshop/$modid ]; then
      ln -s ../../workshop/$modid $modname
    else
      echo Skipping not downloaded mod $modname
    fi
  else
    echo "Found empty modid"
  fi
done < $mod_list
popd > /dev/null

if [ ${WINDOWS:-no} = "no" ]; then
  find -L $mods/ -type f -exec chmod -x {} \;
fi
export WINDOWS
echo "Linking keys"
# maxdepth 3: matches $mod/keys/*.bikey at most, not deeper.
# 3cb has a tendency of creating duplicate keys in $mod/optional/keys/*.bikey,
# which causes unexpected behaviour without the depth limit.
pushd $updated_keys > /dev/null
find -L $mods/ -maxdepth 3 -iname "*.bikey" -exec bash -c 'link_keys "$0"' {} \;
popd > /dev/null

remove_old_keys

echo -n "All mod symlinks updated. "
updatedcount=$(find -L $updated_keys -type f -name "*.bikey" | wc -l)
if [ $updatedcount -eq 0 ]; then
  echo "No new keys were installed."
else
  echo "Following keys were updated:"
  ls $updated_keys
  if [ "$install_keys_automatically" = "yes" ]; then
    install_keys
  else
    while :; do
      read -t10 -p "Do you want to add the keys to the server automatically? (10 seconds timeout) (Y/n): " || ret=$?
      if [ ${ret:-$?} -gt 128 ]; then
        echo "Timed out waiting for user response"
        REPLY=y
      fi
      case $REPLY in
        [nN]*)
          echo "Not installing keys"
          break
        ;;
        [yY]*|*)
          install_keys
          break
        ;;
      esac
    done
  fi
fi

echo "Mods set up"
