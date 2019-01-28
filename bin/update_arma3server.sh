# cd /home/steam/steamcmd

BASEPATH=$HOME
STEAMCMD=/usr/games/steamcmd
INSTALLDIR=$BASEPATH/arma3
STEAMUSERNAME=zeusoperations

#if [ "$1" = "--test" ];
#then
#	echo "Updating test installation"
#	BASEPATH=$HOME/test
#elif [ "$1" = "--exile" ];
#then
#	echo "Updating exile installation"
#	BASEPATH=$HOME/exile
#else
echo "Updating main installation"
#fi

#if [ "$1" = "--all" ];
#then
#	$0 --test
#fi

$STEAMCMD "+login $STEAMUSERNAME +force_install_dir $INSTALLDIR +app_update 233780 validate +exit" | grep -v m_bIsFinalized
