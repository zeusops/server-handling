#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

installpath=mods

source $HOME/files/bin/environment.sh

ALLMODIDS=$(mktemp --tmpdir modids-XXXX.txt)
MODDIR=$INSTALLDIR/steamapps/workshop/content/107410

sort $mod_lists/*.txt -u > $ALLMODIDS

if [ $# -lt 1 ]; then
	echo "Usage: `basename $0` MODID [MODID]..."
	exit 1
fi

mod_ids="$@"

all_mods=""
for mod_id in $mod_ids; do
  all_mods="$all_mods +workshop_download_item 107410 $mod_id validate"
done

cmd="$STEAMCMD +login $STEAMUSERNAME +force_install_dir $STEAMINSTALLDIR $all_mods +quit"
echo $cmd
$cmd
echo

if [ "${WINDOWS-no}" = "no" ]; then
  echo "Turning filenames into lowercase"
  for mod_id in $mod_ids; do
    $LOWERCASE $MODDIR/$mod_id
  done
fi
