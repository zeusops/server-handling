#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh

MODDIR=$install_dir/steamapps/workshop/content/107410

if [ $# -lt 1 ]; then
	echo "Usage: `basename $0` MODID [MODID]..."
	exit 1
fi

mod_ids="$@"

all_mods=""
for mod_id in $mod_ids; do
  all_mods="$all_mods +workshop_download_item 107410 $mod_id validate"
done

cmd="$STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username $all_mods +quit"
echo $cmd
$cmd
echo

if [ "${WINDOWS:-no}" = "no" ]; then
  echo "Turning filenames into lowercase"
  for mod_id in $mod_ids; do
    $lowercase $MODDIR/$mod_id
  done
fi
