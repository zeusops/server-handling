#!/bin/bash
# cd /home/steam/steamcmd

INSTALL_ARMA=yes
source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh

if [ "${1:-}" = "perf" ]; then
  echo Profiling
  branch="-beta profiling -betapassword CautionSpecialProfilingAndTestingBranchArma3"
else
  echo CDLC
  branch="-beta creatordlc"
fi

echo "Updating main installation"


set -x
$STEAMCMD +login $steam_username +force_install_dir $STEAM_INSTALL_DIR +app_update 233780 $branch validate +exit
set +x

$bin/finish-install.sh
