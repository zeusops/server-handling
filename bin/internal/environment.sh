# Sourced by other scripts, not to be executed directly
readonly base_path=${BASE_PATH:-$HOME/server}
readonly files=${FILES:-$base_path/files}
readonly bin=${BIN:-$files/bin}
readonly armadir=${ARMA_DIR:-$base_path/base-installation}
readonly servers=${SERVERS:-$files/servers}
readonly log_files=${LOG_FILES:-$HOME/logs}
readonly workshop=${WORKSHOP:-$armadir/workshop}

readonly mod_lists=${MOD_LISTS:-$files/modlists}
readonly lowercase=${LOWERCASE:-$bin/internal/lowercase-single.sh}

steam_dir=${STEAM_DIR:-$HOME/.steam/steamcmd}
steam_username=${STEAM_USERNAME:-zeusoperations}

. $bin/internal/platform.sh
. $bin/internal/find-steamcmd.sh
