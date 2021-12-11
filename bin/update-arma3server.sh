#!/bin/bash
# cd /home/steam/steamcmd

INSTALL_ARMA=yes
source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh

if [ "${1:-}" = "perf" ]; then
  echo Profiling
  branch="-beta profiling -betapassword CautionSpecialProfilingAndTestingBranchArma3"
elif [ "${1:-}" = "" ]; then
  echo CDLC
  branch="-beta creatordlc"
else
  echo "Usage: $(basename $0) [perf]"
  echo "Updates the CDLC branch by default, specify 'perf' for the performance branch"
  exit 1
fi

echo "Updating main installation"


set -x
$STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username +app_update 233780 $branch validate +exit
set +x

$bin/finish-install.sh
