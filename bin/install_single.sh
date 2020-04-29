#!/bin/bash

set -e

STEAMUSERNAME=zeusoperations

MODLISTS=$HOME/files/modlists
ALLMODIDS=$(mktemp --tmpdir modids-XXXX.txt)
STEAMDIR=$HOME/.steam/steamcmd
INSTALLDIR=$STEAMDIR/mods
MODDIR=$INSTALLDIR/steamapps/workshop/content/107410
BASEPATH=$HOME
LOWERCASE=$BIN/internal/lowercase_single.sh
BIN=$BASEPATH/files/bin
source $BIN/internal/find_steamcmd.sh

sort $MODLISTS/*.txt -u > $ALLMODIDS

if [ -z $1 ]; then
	echo "Usage: `basename $0` modname"
	exit
fi

SEARCHNAME="$1"

ARRAY=($(grep $SEARCHNAME $ALLMODIDS | head -n 1))
# File format:
# @modname 123456
MODNAME=${ARRAY[0]}
MODID=${ARRAY[1]}
echo "Interpreted $SEARCHNAME as $MODNAME with ID $MODID"
read -s -p "Press enter to continue the installation or press ^C to abort"
echo

echo "Downloading mod $MODNAME with ID $MODID"
cmd="$STEAMCMD +login $STEAMUSERNAME +force_install_dir $STEAMINSTALLDIR +workshop_download_item 107410 $MODID validate +quit"
echo $cmd
$cmd
echo

if [ -z $WINDOWS ]; then
  echo "Turning filenames into lowercase"
  $LOWERCASE $MODDIR/$MODID
fi

rm $ALLMODIDS
