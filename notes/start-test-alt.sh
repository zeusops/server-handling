#!/bin/bash

set -x
set -e

NAME=test
PROFILE=test
PORT=2502
#CONFIGPATH=server-handling/config/$NAME.cfg
CONFIGLINK=configlink
CONFIGPATH=$CONFIGLINK\\config\\$NAME.cfg
BASICPATH=$CONFIGLINK\\basic\\basic.cfg
PARAMS=
SERVERMODS=
EXTRAMODS=
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
    if [ ! -d $SERVERPATH ]; then
      mkdir -p $SERVERPATH
      pushd /cygdrive/c/server/arma3 > /dev/null
      for x in *; do
        pushd ../servers/$NAME/arma3 > /dev/null
        ln -s ../../../arma3/$x $x
        popd > /dev/null
      done
      popd > /dev/null
    fi
    if [ ! -d $SERVERPATH/keys ]; then
      mkdir -p $SERVERPATH/keys
    fi
    cd $SERVERPATH
  ;;
esac

update-mods.sh optional --skipdl
update-mods.sh $NAME --skipdl

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
