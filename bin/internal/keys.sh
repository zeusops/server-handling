if [ -z "$BASEPATH" ];
then
	if [ -z "$1" ];
	then
		echo "Usage: $0 basepath foldername"
    exit 1
	fi
	BASEPATH="$1"
fi

if [ -z "$NAME" ];
then
	if [ -z "$2" ];
	then
		echo "Usage: $0 basepath foldername"
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


pushd $BASEPATH/arma3/keys > /dev/null
find . -type l -exec rm {} \;

ln -s ../available_keys/a3.bikey

for key in ../available_keys/$NAME/*; do ln -s $key; done

if [ -d "$BASEPATH/arma3/optional_keys/$NAME" ];
then
	find -L ../optional_keys/$NAME/ -iname "*.bikey" -exec ln -s {} \;
fi
popd > /dev/null
