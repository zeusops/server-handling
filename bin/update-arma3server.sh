#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

INSTALL_ARMA=yes
source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh

cd "$STEAM_INSTALL_DIR"

update() {
  branch=$1

  old_setting=${-//[^x]/}
  $STEAMCMD +force_install_dir $STEAM_INSTALL_DIR +login $steam_username +app_update 233780 $branch validate +exit
  if [[ -n "$old_setting" ]]; then set -x; else set +x; fi
}

update_cdlc() {
  update "-beta creatordlc"
}

update_perf() {
  tmp=$(mktemp -d -p .)
  mv gm spe csla vn ws "$tmp" || true
  update "-beta profiling"
  mv "$tmp/gm" "$tmp/spe" "$tmp/csla" "$tmp/vn" "$tmp/ws" . || true
  rmdir "$tmp"
  ln -s arma3server_x64 arma3server_x64_perf
}

echo "Updating main installation"

case "${1:-}" in
  perf)
    echo Performance
    update_perf
    ;;
  cdlc)
    echo CDLC
    update_cdlc
    ;;
  both)
    echo Both
    update_cdlc
    update_perf
    ;;
  *)
    echo "Usage: $(basename $0) [cdlc|perf|both]"
    echo "Updates the CDLC branch or performance branch or both"
    exit 1
    ;;
esac

$bin/finish-install.sh
