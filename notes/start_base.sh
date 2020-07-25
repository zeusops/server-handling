#!/bin/bash

set -x
set -eufo pipefail

readonly BASEPATH=$HOME
readonly SERVERS=$BASEPATH/files/servers
readonly CONFIGLINK=configlink
readonly BASICPATH=$CONFIGLINK\\basic\\basic.cfg
readonly SERVERPATH=arma3
readonly BIN=$BASEPATH/files/bin


if [ $# -eq 0 ]; then
  echo "Usage: $0 NAME [PORT]"
  echo "If PORT is defined, launch directly. Otherwise, source NAME.sh" \
       "and launch"
  exit 1
fi

if [ $# -eq 1 ]; then
  source $SERVERS/$1.sh
fi

if [ -z ${NAME+x} ]; then
  echo "Missing parameter NAME"
  exit 1
fi
if [ -z ${PORT+x} ]; then
  echo "Missing parameter PORT"
  exit 1
fi

readonly CONFIGPATH=$CONFIGLINK\\config\\$NAME.cfg
readonly profile=${PROFILE:-server}
readonly params=${PARAMS:-}
readonly servermods=${SERVERMODS:-}
readonly extramods=${EXTRAMODS:-}

case $(uname -s) in
  Linux*)
    if grep -q Microsoft /proc/version; then
      cd /mnt/c/server
    else
      cd $HOME
    fi
  ;;
  CYGWIN*)
    SERVERPATH=/cygdrive/c/server/servers/$NAME/arma3
    cd $SERVERPATH
  ;;
esac

update_mods.sh optional --skipdl
update_mods.sh $NAME --skipdl

. $BIN/internal/keys_alt.sh $BASEPATH $NAME

pushd $SERVERPATH > /dev/null
MODS="-mod="
set +x
for x in mods/$NAME/*; do
  MODS=${MODS}\;$x
done
set -x
popd > /dev/null

echo "Launching with mods: $MODS"
echo "Server name: $NAME, port: $PORT"

$SERVERPATH/arma3server_x64 \
  -name=$PROFILE \
  -config=$CONFIGPATH \
  -cfg=$BASICPATH \
  -port=$PORT \
  -filePatching \
  $MODS$EXTRAMODS $SERVERMODS $PARAMS
  #-checkSignatures \
