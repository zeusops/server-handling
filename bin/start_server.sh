#!/bin/sh

if [ -z ${1} ]; then
	echo "Usage: `basename $0` servername"
	exit 1
fi

NAME=$1
BIN=${HOME}/files/bin

$BIN/startscripts/start_arma3server_${NAME}.sh & sleep 2; $BIN/log.sh $NAME ; kill %1
