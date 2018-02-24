# cd /home/steam/steamcmd

BASEPATH=$HOME

if [ "$1" = "--test" ];
then
	echo "Updating test installation"
	BASEPATH=$HOME/test
else
	echo "Updating main installation"
fi

steamcmd +runscript $BASEPATH/update_arma3server.txt

