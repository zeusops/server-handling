#!/bin/bash

set -x
set -e

NAME=gm
PROFILE=server_alt
PORT=2402
#CONFIGPATH=server-handling/config/$NAME.cfg
CONFIGLINK=configlink
CONFIGPATH=$CONFIGLINK\\config\\$NAME.cfg
BASICPATH=$CONFIGLINK\\basic\\basic.cfg
PARAMS=
SERVERMODS=
EXTRAMODS=";gm"
SERVERPATH=arma3
BASEPATH=$HOME
BIN=$BASEPATH/files/bin

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

update-mods.sh optional
update-mods.sh $NAME

. $BIN/internal/keys-alt.sh $BASEPATH $NAME

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
