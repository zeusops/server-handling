#!/bin/bash

#set -eo pipefail
#set -u

if [ -z $1 ]; then echo "Usage: `basename $0` servername [--test] [--skipdl]"; exit 1; fi

readonly STEAMUSERNAME=zeusoperations

readonly NAME=$1

readonly BASEPATH=$HOME
if [ "$2" = "--test" ]; then BASEPATH=$HOME/test; fi
if [ "$2" = "--skipdl" ] || [ "$3" = "--skipdl" ]; then SKIPDOWNLOAD=yes; fi

readonly MODIDS=$BASEPATH/files/modlists/${NAME}.txt
if [ ! -f $MODIDS ]; then echo "$MODIDS not found!"; exit 2; fi

readonly STEAMDIR=$HOME/.steam/steamcmd
readonly INSTALLDIR=$STEAMDIR/mods
readonly ARMADIR=$BASEPATH/arma3
readonly ARMAMODS=$ARMADIR/mods
readonly MODS=$ARMAMODS/$NAME
readonly BIN=$BASEPATH/files/bin
export UPDATEDKEYS=$ARMADIR/updated_keys/$NAME
export AVAILABLEKEYS=$ARMADIR/available_keys/$NAME

source $BIN/internal/find_steamcmd.sh

function link_keys {
  key=$(basename "$1")
  if [ ! -f $AVAILABLEKEYS/$key ]; then
    ln -sv $1 $UPDATEDKEYS/$key
  fi
}

function remove_old_keys {
  echo "Removing old keys"
  find $AVAILABLEKEYS -type l -exec sh -c 'for x; do [ -e "$x" ] || rm -v "$x"; done' _ {} +
}

function install_keys {
  echo "Installing keys"
  find $UPDATEDKEYS -name "*.bikey" -type l -exec mv {} $AVAILABLEKEYS -v \;
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
done < $MODIDS

if [ "$SKIPDOWNLOAD" != "yes" ]; then
  echo "Updating mods"
  $STEAMCMD +login $STEAMUSERNAME +force_install_dir $STEAMINSTALLDIR $allmods +quit
  echo
else
  echo "Updating mod keys. This does not download updates"
fi

echo "Creating folders"
if [ ! -d $MODS ]; then mkdir -p $MODS; fi
if [ ! -d $UPDATEDKEYS ]; then mkdir -p $UPDATEDKEYS; fi
if [ ! -d $AVAILABLEKEYS ]; then mkdir -p $AVAILABLEKEYS; fi

echo "Removing old mod links"
find $MODS -type l -exec rm {} \;
echo "Removing old key links"
find $UPDATEDKEYS -type l -exec rm {} \;

missing=""

echo "Linking mods"
while read line; do
  # Skip line if it starts with a #
  [[ $line =~ ^#.* ]] && continue

  array=($line)
  if ! [ -z $array ]; then
    ALLMODS="$ALLMODS +workshop_download_item 107410 $MODID"

    # File format:
    # @modname 123456
    modname=${array[0]}
    modid=${array[1]}
    modpath=$MODS/$modname
    if [ -e $modpath ]; then
      rm $modpath
    fi
    moddlpath=$INSTALLDIR/steamapps/workshop/content/107410/$modid
    if [ ! -e $moddlpath ]; then
      echo $moddlpath
      echo "$modname with ID $modid missing! Run `basename $0` $NAME or install_single.sh $modname"
      missing="$missing $modname"
    else
      ln -sv $moddlpath $modpath
      if [ "$SKIPDOWNLOAD" != "yes" ] && [ -z $WINDOWS ]; then
        $BASEPATH/files/bin/internal/lowercase_single.sh $modpath/
      fi
    fi
  else
    echo "Found empty modid"
  fi
done < $MODIDS

if [ ! -z "${missing}" ]; then
  echo "Missing mods: $missing"
  exit 1
fi

if [ -z $WINDOWS ]; then
  find -L $MODS/ -type f -exec chmod -x {} \;
fi
find -L $MODS/ -iname "*.bikey" -exec bash -c 'link_keys "$0"' {} \;

updatedcount=$(ls -1 $UPDATEDKEYS/*.bikey 2> /dev/null | wc -l)  # Does not work with spaces in filenames
remove_old_keys
echo -n "All mods updated. "
if [ $updatedcount -eq 0 ]; then
  echo "No new keys were installed."
else
  echo "Following keys were updated:"
  ls $UPDATEDKEYS
  while :; do
    read -t10 -p "Do you want to add the keys to the server automatically? (10 seconds timeout) (Y/n): "
    if [ $? -gt 128 ]; then
      echo "Timed out waiting for user response"
      install_keys
      break
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
