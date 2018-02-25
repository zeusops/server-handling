#!/bin/sh

if [ -z $1 ]; then echo "Usage: `basename $0` servername [--test]"; exit 1; fi

BASEPATH=$HOME

if [ "$2" = "--test" ];
then
	BASEPATH=$HOME/test
fi

NAME=$1
BIN=$BASEPATH/files/bin

. $BIN/startscripts/${NAME}.sh

if [ -z $NOKEYS ]; then . $BIN/keys.sh; fi
if [ -z $MODS ]; then . $BIN/automods.sh; fi

. $BIN/real_server.sh &

sleep 2
$BIN/log.sh $NAME
kill %1
