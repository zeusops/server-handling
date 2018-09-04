#!/bin/sh
set -e

STEAMUSERNAME=zeusoperations

ARMADIR=$HOME/arma3
MPMISSIONS=$ARMADIR/mpmissions
STEAMDIR=$HOME/.steam/steamcmd
INSTALLDIR=$STEAMDIR/missions
BACKUPMISSIONS=$ARMADIR/backupmissions
STEAMCMD=/usr/games/steamcmd

if [ -z $2 ]; then
	echo "Usage $0 missionid missionname.map"
	exit
fi

MISSIONID="$1"
MISSIONNAME="${2}.pbo"

echo "Downloading mission file $MISSIONID to ${MISSIONNAME}"
cd $STEAMDIR
$STEAMCMD +login $STEAMUSERNAME +force_install_dir $INSTALLDIR +workshop_download_item 107410 $MISSIONID validate +quit
echo
if [ -e $MPMISSIONS/$MISSIONNAME ]; then
	if [ -L $MPMISSIONS/$MISSIONNAME ]; then
		rm $MPMISSIONS/$MISSIONNAME
	elif [ -f $MPMISSIONS/$MISSIONNAME ]; then
		echo "Existing mission file is not a symbolic link. Backing up"
		mv -v $MPMISSIONS/$MISSIONNAME $BACKUPMISSIONS/${MISSIONNAME}_backup_$(date +%Y%m%d-%H%M%S)
	else
		echo "$MPMISSIONS/$MISSIONNAME is unexpected type. Aborting"
		exit
	fi
fi

if [ ! -e $INSTALLDIR/steamapps/workshop/content/107410/$MISSIONID/*.bin ]; then
	echo "Couldn't find the downloaded file in $INSTALLDIR/steamapps/workshop/content/107410/$MISSIONID/. Aborting"
	exit
fi

echo "Linking mission file"
ln -s $INSTALLDIR/steamapps/workshop/content/107410/$MISSIONID/*.bin $MPMISSIONS/$MISSIONNAME
echo "Mission file downloaded"
