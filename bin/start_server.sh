#!/bin/bash
# TODO: 2018-02-14 Disable filePatchng?
trap cleanup EXIT

function cleanup {
	echo "Killing $PID"
	kill $PID
}

if [ -z $1 ]; then echo "Usage: `basename $0` servername [--test]"; exit 1; fi

BASEPATH=$HOME

if [ "$2" = "--test" ];
then
	BASEPATH=$HOME/test
fi

NAME=$1
BIN=$BASEPATH/files/bin

. $BIN/startscripts/${NAME}.sh
if [ -z $PROFILE ]; then PROFILE=server_main; fi
if [ -z $CONFIG ]; then CONFIG=$NAME; fi

if [ -z $NOKEYS ]; then . $BIN/internal/keys.sh; fi
if [ -z $MODS ]; then . $BIN/internal/automods.sh; fi

CONFIGPATH=$BASEPATH/files/config/${CONFIG}.cfg
LOGPATH=$BASEPATH/log/

cd $BASEPATH/arma3

echo "Starting server $NAME on `date` on port $PORT"
./arma3server   -name=$PROFILE \
                -config=$CONFIGPATH \
                -port=$PORT \
                -filePatching \
                -enableHT \
                -maxMem=12287 \
                $MODS $SERVERMODS $PARAMS \
                1>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt" \
                2>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt" &
PID=$!
echo "PID: $PID"
sleep 2
$BIN/log.sh $NAME
