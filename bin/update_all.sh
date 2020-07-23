#!/bin/bash
set -e

STEAMUSERNAME=zeusoperations

BASEPATH=$HOME
MODLISTS=$BASEPATH/files/modlists
ALLMODS=$MODLISTS/allmods.txt
ALLMODIDS=$(mktemp --tmpdir modids-XXXX.txt)
STEAMDIR=$HOME/.steam/steamcmd
INSTALLDIR=$STEAMDIR/mods
BIN=$BASEPATH/files/bin
LOWERCASE=$BIN/internal/lowercase_single.sh
source internal/find_steamcmd.sh

# sort $MODLISTS/*.txt -u | grep -v '^#.*$' > $ALLMODIDS
grep -v '^#.*$' $ALLMODS > $ALLMODIDS

modparam=""
while read line; do
	ARRAY=($line)
	# File format:
	# @modname 123456
	MODID=${ARRAY[1]}
	if ! [ -z $MODID ]; then
		modparam="$modparam +workshop_download_item 107410 $MODID"
	else
		echo "Found empty modid"
	fi
done < $ALLMODIDS

echo $modparam
echo $INSTALLDIR

echo "Updating mods"
$STEAMCMD +login $STEAMUSERNAME +force_install_dir $STEAMINSTALLDIR $modparam +quit

while read line; do
	array=($line)
	# File format:
	# @modname 123456
	MODID=${array[1]}
	$LOWERCASE $INSTALLDIR/steamapps/workshop/content/107410/$MODID
done < $ALLMODIDS

rm $ALLMODIDS
