if [ -z $NAME ]; then echo "Server name not set"; exit 1; fi

# TODO: 2018-02-14 Disable filePatchng?

echo "Starting server $NAME on `date` on port $PORT"
./arma3server -name=$PROFILE -config=../files/config/server_${CONFIG}.cfg -port=$PORT -filePatching -enableHT -maxMem=12287 $MODS $SERVERMODS $PARAMS \
 1>>"/home/steam/log/arma3server_${NAME}_$(date +%s).rpt" 2>>"/home/steam/log/arma3server_${NAME}_$(date +%s).rpt"

