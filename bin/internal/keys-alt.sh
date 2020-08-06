#!/bin/sh
set -x
#set -e
if [ -z "$BASEPATH" ];
then
	if [ -z "$1" ];
	then
		echo "Usage: $0 arma3basepath modname"
    exit 1
	fi
	BASEPATH="$1"
fi

if [ -z "$NAME" ];
then
	if [ -z "$2" ];
	then
		echo "Usage: $0 arma3basepath modname"
		exit 1
	fi
	NAME="$2"
fi

if [ ! -d "$BASEPATH/arma3/available_keys" ];
then
  echo "Creating folder $BASEPATH/arma3/available_keys"
  mkdir -p "$BASEPATH/arma3/available_keys"
fi

if [ ! -d "$BASEPATH/arma3/available_keys/$NAME" ];
then
	echo "Folder $BASEPATH/arma3/available_keys/$NAME not found!"
	exit 2
fi


keypath=$BASEPATH/server/servers/$NAME/arma3/keys
mkdir -p $keypath
pushd $keypath > /dev/null
find . -type l -exec rm {} \;

ln -s ../available_keys/a3.bikey || true

for key in $(find ../available_keys/$NAME -xtype f); do ln -s $key; done

if [ -d "$BASEPATH/arma3/optional_keys/$NAME" ];
then
	find -L ../optional_keys/$NAME/ -iname "*.bikey" -exec ln -s {} \;
fi
popd > /dev/null
