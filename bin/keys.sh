if [ -z "$NAME" ];
then
	if [ -z "$1" ];
	then
		echo "Usage: $0 foldername"
		exit 1
	fi
	NAME="$1"
fi
if [ ! -d "/home/steam/test/arma3/availablekeys/$NAME" ];
then
	echo "Folder /home/steam/test/arma3/availablekeys/$NAME not found!"
	exit 2
fi
cd /home/steam/test/arma3/keys
find . -type l -exec rm {} \;

for x in ../availablekeys/$NAME/*; do ln -s $x; done
