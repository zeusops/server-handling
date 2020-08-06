BASEPATH="${BASEPATH:-$HOME}"
ARMADIR=$BASEPATH/arma3
BIN=$BASEPATH/files/bin

MODLISTS=$BASEPATH/files/modlists
LOWERCASE=$BIN/internal/lowercase-single.sh

STEAMDIR=$HOME/.steam/steamcmd
STEAMUSERNAME=zeusoperations
. $BIN/internal/platform.sh
. $BIN/internal/find-steamcmd.sh
