#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

if [ -z "${1-}" ]; then echo "Usage: `basename $0` servername [--skipdl] [--missing]"; exit 1; fi

readonly name="$1"
if [ "${2:-}" = "--skipdl" ] || [ "${3:-}" = "--skipdl" ]; then skip_download=yes; fi
if [ "${2:-}" = "--missing" ] || [ "${3:-}" = "--missing" ]; then skip_download=yes; download_missing=yes; fi

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
  target="$(realpath $1)"
  link_name="$(realpath $2)"
  echo "target $target"
  echo "link_name $link_name"
  echo "dirname $(dirname $link_name)"
  echo "win $WINDOWS"
  if [ ${WINDOWS:-no} = "yes" ]; then
    path=$(realpath --relative-to=$(dirname $link_name) $target)
    echo "path $path"
  else
    path=$target
  fi
  ln -s $verbose $force $path $link_name
}

export -f symlink

function link_keys {
  echo "link_keys param $1"
  key=$(basename "$1")
  echo "key $key"
  if [ ! -f $available_keys/$key ]; then
    symlink -vf $1 $updated_keys/$key
  fi
}

function remove_old_keys {
  echo "Removing old keys"
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
}


export -f link_keys

allmods=""
while read line; do
  # Skip line if it starts with a #
  [[ $line =~ ^#.* ]] && continue

  array=($line)
  # File format:
  # @modname 123456
  modid=${array[1]}
  if ! [ -z $modid ]; then
    allmods="$allmods +workshop_download_item 107410 $modid validate"
  else
    echo "Found empty modid"
  fi
done < $mod_list

if [ "${skip_download:-no}" != "yes" ]; then
  echo "Updating mods"
  $STEAMCMD +login $steam_username +force_install_dir $STEAM_INSTALL_DIR $allmods +quit
  echo
else
  echo "Updating mod keys. This does not download updates"
fi

echo "Creating folders"
if [ ! -d $mods ]; then mkdir -p $mods; fi
if [ ! -d $updated_keys ]; then mkdir -p $updated_keys; fi
if [ ! -d $available_keys ]; then mkdir -p $available_keys; fi

echo "Removing old mod links"
find $mods -type l -exec rm {} \;
echo "Removing old key links"
find $updated_keys -type l -exec rm {} \;

missing=""
missingid=""

echo "Linking mods"
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
    moddlpath=$install_dir/steamapps/workshop/content/107410/$modid
    if [ ! -e $moddlpath ]; then
      echo $moddlpath
      echo "$modname with ID $modid missing! Run `basename $0` $name or install-single.sh $modname"
      missing="$missing $modname"
      missingid="$missingid $modid"
    else
      symlink -v $moddlpath $modpath
      if [ "${skip_download:-no}" != "yes" ] && [ -z $WINDOWS ]; then
        $bin/internal/lowercase-single.sh $modpath/
      fi
    fi
  else
    echo "Found empty modid"
  fi
done < $mod_list

if [ ! -z "$missing" ]; then
  echo "Missing mods: $missing"
  if [ -z "$download_missing" ]; then
    while :; do
      read -t10 -p "Do you want to install the missing mods to the server automatically? (10 seconds timeout) (y/N): " || ret=$?
      if [ ${ret:-$?} -gt 128 ]; then
        echo "Timed out waiting for user response"
        break
      fi

      case $REPLY in
        [nN]*)
          echo "Not installing mods"
          break
        ;;
        [yY]*|*)
          install_mods
          break
        ;;
      esac
    done
  else
    install_mods
  fi
fi

if [ ${WINDOWS:-no} == "no" ]; then
  find -L $mods/ -type f -exec chmod -x {} \;
fi
export WINDOWS
find -L $mods/ -iname "*.bikey" -exec bash -c 'link_keys "$0"' {} \;

updatedcount=$(find -L $updated_keys -type f -name "*.bikey" | wc -l)  # Does not work with spaces in filenames
remove_old_keys
echo -n "All mods updated. "
if [ $updatedcount -eq 0 ]; then
  echo "No new keys were installed."
else
  echo "Following keys were updated:"
  ls $updated_keys
  while :; do
    read -t10 -p "Do you want to add the keys to the server automatically? (10 seconds timeout) (Y/n): " || ret=$?
    if [ ${ret:-$?} -gt 128 ]; then
      echo "Timed out waiting for user response"
      REPLY=y
    fi
    case $REPLY in
      [nN]*)
        echo "Not istalling keys"
        break
      ;;
      [yY]*|*)
        install_keys
        break
      ;;
    esac
  done
fi

echo "Mods updated"
