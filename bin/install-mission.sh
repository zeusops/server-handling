#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

INSTALL_PATH=missions
source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh

mpmissions=$armadir/mpmissions
backup_missions=$armadir/backupmissions

if [ -z "${2:-}" ]; then
	echo "Usage $0 missionid missionname.map"
	exit
fi

mission_id="$1"
mission_name="${2}.pbo"

echo "Downloading mission file $mission_id to ${mission_name}"
cd $steam_dir
$STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username +workshop_download_item 107410 $mission_id validate +quit | grep -v m_bIsFinalized
echo
if [ -e $mpmissions/$mission_name ]; then
	if [ -L $mpmissions/$mission_name ]; then
		rm $mpmissions/$mission_name
	elif [ -f $mpmissions/$mission_name ]; then
		echo "Existing mission file is not a symbolic link. Backing up"
		mv -v $mpmissions/$mission_name $backup_missions/${mission_name}_backup_$(date +%Y%m%d-%H%M%S)
	else
		echo "$mpmissions/$mission_name is unexpected type. Aborting"
		exit
	fi
fi

if [ ! -e $STEAM_INSTALL_DIR/steamapps/workshop/content/107410/$mission_id/*.bin ]; then
	echo "Couldn't find the downloaded file in $STEAM_INSTALL_DIR/steamapps/workshop/content/107410/$mission_id/. Aborting"
	exit
fi

echo "Linking mission file"
ln -s $STEAM_INSTALL_DIR/steamapps/workshop/content/107410/$mission_id/*.bin $mpmissions/$mission_name
echo "Mission file downloaded"
