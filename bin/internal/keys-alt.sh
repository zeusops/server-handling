#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh

name=${1-${NAME:-${name-}}}
if [ -z "$name" ];
then
	echo "Usage: $(basename $0) MODNAME"
	exit 1
fi
if [ ! -d "$armadir/available_keys" ];
then
  echo "Creating folder $armadir/available_keys"
  mkdir -p "$armadir/available_keys"
fi

if [ ! -d "$armadir/available_keys/$name" ];
then
	echo "Folder $armadir/available_keys/$name not found!"
	exit 2
fi

keypath=$base_path/instances/$name/arma3/keys
mkdir -p $keypath
pushd $keypath > /dev/null
find . -type l -exec rm {} \;

ln -s ../available_keys/a3.bikey || true

for key in $(find ../available_keys/$name -xtype f); do ln -s $key; done

if [ -d "$armadir/optional_keys/$name" ];
then
	find -L ../optional_keys/$name/ -iname "*.bikey" -exec ln -s {} \;
fi
popd > /dev/null
