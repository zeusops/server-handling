if [ -z $NAME ]; then echo "Server name not set"; exit 1; fi

# TODO: 2018-02-14 Disable filePatchng?

CONFIGPATH=${HOME}/files/config/
LOGPATH=${HOME}/log/

echo "Starting server $NAME on `date` on port $PORT"
./arma3server -name=$PROFILE -config=$CONFIGPATH/${CONFIG}.cfg -port=$PORT -filePatching -enableHT -maxMem=12287 $MODS $SERVERMODS $PARAMS \
 1>>"$LOGPATH/${NAME}_$(date +%s).rpt" 2>>"$LOGPATH/${NAME}_$(date +%s).rpt"

