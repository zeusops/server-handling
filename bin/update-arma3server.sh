#!/bin/bash
# cd /home/steam/steamcmd

INSTALL_ARMA=yes
source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh

echo "Updating main installation"

set -x
$STEAMCMD +login $steam_username +force_install_dir $STEAM_INSTALL_DIR +app_update 233780 -beta creatordlc validate +exit
set +x

$bin/finish-install.sh
