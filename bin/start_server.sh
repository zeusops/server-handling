#!/bin/bash
# TODO: 2018-02-14 Disable filePatchng?
# TODO: 2018-02-27 Check if server config files exist

trap cleanup INT

function cleanup {
	echo "Killing $PID"
	kill $PID
}

function servername {
	SRV=$(basename $1)
	echo $SRV | sed 's/.sh//'
}

export -f servername

if [ -z $1 ]; then echo "Usage: `basename $0` --list | servername [--test]"; exit 1; fi

BASEPATH=$HOME

if [ "$2" = "--test" ];
then
	BASEPATH=$HOME/test
fi

if [ "$1" = "--list" ];
then
	echo "Available servers:"
	find $BASEPATH/files/servers -name "*.sh" -exec bash -c 'servername "$0"' {} \;
	exit 0
fi

NAME=$1
BIN=$BASEPATH/files/bin


. $BASEPATH/files/servers/${NAME}.sh
if [ -z $PROFILE ]; then PROFILE=server; fi
if [ -z $CONFIG ]; then CONFIG=$NAME; fi

# If $MODS has been defined already, we're not doing mod autodetection or key updating
if [ -z $MODS ]
then
	$BIN/update_mods.sh $NAME --skipdl
	. $BIN/internal/automods.sh
fi
if [ -z $NOKEYS ]; then . $BIN/internal/keys.sh; fi

CONFIGPATH=$BASEPATH/files/config/${CONFIG}.cfg
LOGPATH=$BASEPATH/log/
if [ ! -d $LOGPATH ]; then mkdir -p $LOGPATH; fi

if [ ! -d $BASEPATH/arma3 ]; then echo "Arma 3 server not installed"; exit; fi
cd $BASEPATH/arma3

echo "Starting server $NAME on `date` on port $PORT"
./arma3server   -name=$PROFILE \
                -config=$CONFIGPATH \
                -port=$PORT \
                -enableHT \
                -maxMem=12287 \
                -filePatching \
                $MODS $SERVERMODS $PARAMS \
                1>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt" \
                2>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt" &

PID=$!
echo "PID: $PID"
sleep 2
$BIN/log.sh $NAME $BASEPATH
