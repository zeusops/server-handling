# cd /home/steam/steamcmd

BASEPATH=$HOME

if [ "$1" = "--test" ];
then
	echo "Updating test installation"
	BASEPATH=$HOME/test
elif [ "$1" = "--exile" ];
then
	echo "Updating exile installation"
	BASEPATH=$HOME/exile
else
	echo "Updating main installation"
fi

if [ "$1" = "--all" ];
then
	$0 --test
fi

steamcmd +runscript $BASEPATH/update_arma3server.txt

