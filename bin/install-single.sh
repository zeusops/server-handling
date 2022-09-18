#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh

all_mod_ids=$(mktemp --tmpdir modids-XXXX.txt)
mod_dir=$STEAM_INSTALL_DIR/steamapps/workshop/content/107410

sort $mod_lists/*.txt -u > $all_mod_ids

if [ -z "${1:-}" ]; then
	echo "Usage: `basename $0` modname [skip prompt]"
	exit
fi

search_name="$1"
skip=${2:-}

array=($(grep $search_name $all_mod_ids | head -n 1))
# File format:
# @modname 123456
mod_name=${array[0]}
mod_id=${array[1]}

if [ -z $skip ]; then
  echo "Interpreted $search_name as $mod_name with ID $mod_id"
  read -s -p "Press enter to continue the installation or press ^C to abort"
  echo
fi

echo "Downloading mod $mod_name with ID $mod_id"
cmd="$STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username +workshop_download_item 107410 $mod_id validate +quit"
echo $cmd
$cmd
echo

if [ -z $WINDOWS ]; then
  echo "Turning filenames into lowercase"
  $lowercase $mod_dir/$mod_id
fi

rm $all_mod_ids
