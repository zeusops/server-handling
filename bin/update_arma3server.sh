#!/bin/bash
# cd /home/steam/steamcmd

BASEPATH=$HOME
INSTALLDIR=$BASEPATH/arma3
STEAMUSERNAME=zeusoperations
BIN=$BASEPATH/files/bin
source $BIN/internal/find_steamcmd.sh

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

echo $STEAMCMD +login $STEAMUSERNAME +force_install_dir $STEAMINSTALLDIR +app_update 233780 validate +exit
$STEAMCMD "+login $STEAMUSERNAME +force_install_dir $STEAMINSTALLDIR +app_update 233780 validate +exit"
finish_install.sh
