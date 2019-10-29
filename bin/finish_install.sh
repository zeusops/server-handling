#!/bin/sh

set -e

BASEPATH=$HOME
LINK=$HOME/link
ARMA=$BASEPATH/arma3

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
  ln -vs $LINK/$dir $ARMA/$dir
fi

for dir in A3Antistasi available_keys logs mods optional_keys tmpmissions updated_keys userconfig; do
  if [ ! -L $ARMA/$dir ]; then
    if [ -d $ARMA/$dir ]; then
      rmdir -v $ARMA/$dir
    elif [ -e $ARMA/$dir ]; then
      echo "$ARMA/$dir exists"
      exit 1
    fi
    ln -vs $LINK/$dir $ARMA/$dir
  fi
done

