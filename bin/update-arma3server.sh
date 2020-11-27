#!/bin/bash
# cd /home/steam/steamcmd

BASEPATH=$HOME
INSTALLDIR=$BASEPATH/arma3
STEAMUSERNAME=zeusoperations
BIN=$BASEPATH/files/bin
source $BIN/internal/find-steamcmd.sh

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

cmd="$STEAMCMD +login $STEAMUSERNAME +force_install_dir $STEAMINSTALLDIR +app_update 233780 -beta creatordlc validate +exit"
echo $cmd
$cmd

$BIN/finish-install.sh