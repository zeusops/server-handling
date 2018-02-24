if [ -z "$1" ];
then
	echo "Usage: $0 foldername"
	exit 1
fi
if [ ! -d "/home/steam/test/arma3/availablekeys/$1" ];
then
	echo "Folder /home/steam/test/arma3/availablekeys/$1 not found!"
	exit 2
fi
cd /home/steam/test/arma3/keys
find . -type l -exec rm {} \;

for x in ../availablekeys/$1/*; do ln -s $x; done
