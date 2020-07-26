#!/bin/bash

set -e

installpath=mods

source $HOME/test/files/bin/environment.sh

MODLISTS=$BASEPATH/files/modlists
ALLMODIDS=$(mktemp --tmpdir modids-XXXX.txt)
MODDIR=$STEAMINSTALLDIR/steamapps/workshop/content/107410

sort $MODLISTS/*.txt -u > $ALLMODIDS

if [ -z $1 ]; then
	echo "Usage: `basename $0` modname [skip prompt]"
	exit
fi

SEARCHNAME="$1"
SKIP=${2:-}

ARRAY=($(grep $SEARCHNAME $ALLMODIDS | head -n 1))
# File format:
# @modname 123456
MODNAME=${ARRAY[0]}
MODID=${ARRAY[1]}

if [ -z $SKIP ]; then
  echo "Interpreted $SEARCHNAME as $MODNAME with ID $MODID"
  read -s -p "Press enter to continue the installation or press ^C to abort"
  echo
fi

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
