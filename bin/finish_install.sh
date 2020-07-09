#!/bin/sh

set -e

readonly BASEPATH=$HOME
readonly BIN=$BASEPATH/files/bin
. $BIN/internal/platform.sh

readonly LINK=$HOME/link
readonly ARMA=$BASEPATH/arma3
readonly AVAILABLEKEYS=$LINK/available_keys
readonly OPTIONALKEYS=$LINK/optional_keys
readonly CONFIGLINK=$ARMA/configlink


dir=mpmissions
if [ ! -L $ARMA/$dir ]; then
  if [ -d $ARMA/$dir ]; then
    if [ -f $ARMA/$dir/readme.txt ]; then
      rm -v $ARMA/$dir/readme.txt
    fi
    rmdir -v $ARMA/$dir
  elif [ -e $ARMA/$dir ]; then
    echo "$ARMA/$dir exists"
    exit 1
  fi
  if [ ! -d $LINK/$dir ]; then
    mkdir -p $LINK/$dir
  fi
  ln -vs $(readlink -e $LINK/$dir) $ARMA/$dir
fi

#for dir in A3Antistasi available_keys logs mods optional_keys tmpmissions updated_keys userconfig; do
for dir in available_keys logs mods optional_keys tmpmissions updated_keys userconfig; do
  if [ ! -L $ARMA/$dir ]; then
    if [ -d $ARMA/$dir ]; then
      rmdir -v $ARMA/$dir
    elif [ -e $ARMA/$dir ]; then
      echo "$ARMA/$dir exists"
      exit 1
    fi
    mkdir -p $LINK/$dir
    ln -vs $(readlink -e $LINK/$dir) $ARMA/$dir
  fi
done

if [ $PLATFORM = "cygwin" ]; then
  if [ ! -L $CONFIGLINK ]; then
    if [ -d $CONFIGLINK ]; then
      rmdir -v $CONFIGLINK
    elif [ -e $CONFIGLINK ]; then
      echo "$CONFIGLINK exists"
      exit 1
    fi
    ln -vs $(readlink -e /cygdrive/c/server/server-handling) $ARMA/configlink
  fi
fi

if [ ! -e $OPTIONALKEYS/main ]; then
  ln -vs $AVAILABLEKEYS/optional $OPTIONALKEYS/main
fi
