#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

readonly name=${1:-}; shift || true
if [ -z "$name" ]; then
  echo "Usage: $(basename $0) servername [--skipdl] [--all] [--keys] [--prompt] [--no-missing] [--check-only]"
  echo "OPTIONS"
  echo "  --skipdl      Skip all downloads"
  echo "  --all         Redownload all mods"
  echo "  --keys        Install keys automatically"
  echo "  --prompt      Show a confirmation prompt before downloading missing mods"
  echo "  --no-missing  Do not install missing mods"
  echo "  --check-only  Only check for updates, do not download"
  exit 1
fi

prompt_missing=no
skip_downloads=no
install_keys_automatically=no
force_download=no
install_missing=yes
check_only=no
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
  esac
  shift
done

source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh
readonly mods=$armadir/mods/$name
export updated_keys=$armadir/updated_keys/$name
export available_keys=$armadir/available_keys/$name

readonly mod_list="$mod_lists/$name.txt"
if [ ! -f "$mod_list" ]; then echo "Mod list $mod_list not found!"; exit 2; fi

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
  if [ ! -f $available_keys/$key_name ]; then
    path=$(relpath $key_path $updated_keys)
    #echo path $path
    #symlink -vf $path $updated_keys/$key_name
    ln -svf $path $updated_keys/$key_name
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
if [ "$skip_downloads" = "no" ]; then
  # Run the DB update, fetching the current mod update dates from the Workshop
  path_data=$files/data
  mkdir -p $path_data
  update_status=0
  if [ "${install_missing:-yes}" != "yes" ]; then
    flag="-e"
  fi
  $bin/internal/workshop-checker/update_db.sh -c -m ${flag:-} \
      -s $path_data/versions_local_state_$name.json $allmodids || update_status=$?
  if [ "$update_status" != "0" ] && [ "$update_status" != "1" ]; then
    echo "Failed to check mod update status. Exiting"
    exit "$update_status"
  fi

  if [ "${check_only:-no}" = "yes" ]; then
    exit
  fi
  if [ "$force_download" = "yes" ]; then
    echo "Updating all mods (forced)..."
    $STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username $allmods +quit
    echo
    did_update="yes"
  elif [ "$update_status" = "1" ]; then
    echo "Updating only updated mods..."
    for modid in "${allmodids_array[@]}"
    do
      modname=${mod_names[$modid]}
      echo "Checking mod $modname ($modid)"
      mod_status=0
      $bin/internal/workshop-checker/check_update.sh -s $path_data/versions_local_state_$name.json ${flag:-} $modid || mod_status=$?
      if [ "$mod_status" = "1" ]; then
        # TODO: mail
        echo "Detected update for mod $modname, running Steam update."
        $STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username +workshop_download_item 107410 $modid validate +quit
        echo
        did_update="yes"
      fi
    done
  fi
fi
if [ "$did_update" = "yes" ]; then
  # Run the script from the start without downloading to set up symlinks and keys
  $0 $name --skipdl
  exit
else
  echo "Updating mod keys. This does not download updates!"
fi

echo "Creating folders"
if [ ! -d $mods ]; then mkdir -p $mods; fi
if [ ! -d $updated_keys ]; then mkdir -p $updated_keys; fi
if [ ! -d $available_keys ]; then mkdir -p $available_keys; fi

echo "Removing old mod links"
find $mods -type l -exec rm {} \;
echo "Removing old key links"
find $updated_keys -type l -exec rm {} \;

if [ "$skip_downloads" = "no" ] && [ ! -z "${missing_name:-}" ]; then
  echo "Missing mods: $missing_name"
  if [ "${install_missing:-yes}" = "yes" ]; then
    if [ "${prompt_missing:-no}" = "no" ]; then
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
      ln -s ../../workshop/$modid $modpath
    else
      echo Skipping not downloaded mod $modpath
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
find -L $mods/ -maxdepth 3 -iname "*.bikey" -exec bash -c 'link_keys "$0"' {} \;

remove_old_keys

echo -n "All mod symlinks updated. "
updatedcount=$(find -L $updated_keys -type f -name "*.bikey" | wc -l)
if [ $updatedcount -eq 0 ]; then
  echo "No new keys were installed."
else
  echo "Following keys were updated:"
  ls $updated_keys
  if [ "${install_keys_automatically:-no}" = "yes" ]; then
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

echo "Mods updated"
