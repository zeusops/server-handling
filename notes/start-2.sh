#!/bin/bash

set -x
set -e

case $(uname -s) in
  Linux*)
    if grep -q Microsoft /proc/version; then
      cd /mnt/c/server
    else
      cd $HOME
    fi
  ;;
  CYGWIN*)
    cd /cygdrive/c/server
  ;;
esac

NAME=second
PROFILE=server2
PORT=2402
#CONFIGPATH=server-handling/config/$NAME.cfg
CONFIGLINK=configlink
CONFIGPATH=$CONFIGLINK\\config\\$NAME.cfg
BASICPATH=$CONFIGLINK\\basic\\basic.cfg
PARAMS=
SERVERMODS=
SERVERPATH=arma3
BASEPATH=$HOME
BIN=$BASEPATH/files/bin


#update-mods.sh optional --skipdl
#update-mods.sh $NAME --skipdl

#. $BIN/internal/keys.sh $BASEPATH $NAME

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

echo "Server name: $NAME, port: $PORT"

$SERVERPATH/arma3server_x64 \
  -name=$PROFILE \
  -config=$CONFIGPATH \
  -cfg=$BASICPATH \
  -port=$PORT \
  -filePatching \
  -bepath=battleye-test \
  $MODS $SERVERMODS $PARAMS
  #-checkSignatures \
