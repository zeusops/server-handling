#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

INSTALL_ARMA=yes
source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh

if [ "${1:-}" = "perf" ]; then
  echo Profiling
  branch="-beta profiling"
elif [ "${1:-}" = "" ]; then
  echo CDLC
  branch="-beta creatordlc"
else
  echo "Usage: $(basename $0) [perf]"
  echo "Updates the CDLC branch by default, specify 'perf' for the performance branch"
  exit 1
fi

echo "Updating main installation"


old_setting=${-//[^x]/}
$STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username +app_update 233780 $branch validate +exit
if [[ -n "$old_setting" ]]; then set -x; else set +x; fi

$bin/finish-install.sh
