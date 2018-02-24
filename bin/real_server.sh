if [ -z $NAME ]; then echo "Server name not set"; exit 1; fi
if [ -z $BASEPATH ]; then echo "Basepath not set"; exit 1; fi
# TODO: 2018-02-14 Disable filePatchng?

CONFIGPATH=$BASEPATH/files/config/
LOGPATH=$BASEPATH/log/

cd $BASEPATH/arma3

echo "Starting server $NAME on `date` on port $PORT"
./arma3server 	-name=$PROFILE \
		-config=$CONFIGPATH/${CONFIG}.cfg \
		-port=$PORT \
		-filePatching \
		-enableHT \
		-maxMem=12287 \
		$MODS $SERVERMODS $PARAMS \
		1>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt" \
		2>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt"

# tail -f "/home/steam/test/log/arma3server_${NAME}_$(date +%s).rpt" | grep -v "base class"
