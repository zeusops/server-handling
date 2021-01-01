readonly base_path=${BASE_PATH:-$HOME/server}
readonly bin=${BIN:-${base_path}/files/bin}
readonly armadir=${ARMA_DIR:-${base_path}/base-installation}
readonly servers=${SERVERS:-${base_path}/files/servers}

readonly mod_lists=${MOD_LISTS:-${base_path}/files/modlists}
readonly lowercase=${LOWERCASE:-${bin}/internal/lowercase-single.sh}

steam_dir=${STEAM_DIR:-$HOME/.steam/steamcmd}
steam_username=${STEAM_USERNAME:-zeusoperations}

. $bin/internal/platform.sh
. $bin/internal/find-steamcmd.sh
