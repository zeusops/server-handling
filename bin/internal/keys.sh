if [ -z "$BASEPATH" ];
then
	if [ -z "$1" ];
	then
		echo "Usage: $0 basepath foldername"
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

if [ ! -d "$BASEPATH/arma3/available_keys/$NAME" ];
then
	echo "Folder $BASEPATH/arma3/available_keys/$NAME not found!"
	exit 2
fi
cd $BASEPATH/arma3/keys
find . -type l -exec rm {} \;

for x in ../available_keys/$NAME/*; do ln -s $x; done
