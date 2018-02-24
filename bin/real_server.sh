if [ -z $NAME ]; then echo "Server name not set"; exit 1; fi

cd /home/steam/test/arma3

echo "Starting server $NAME on `date` on port $PORT"
./arma3server -name=$PROFILE -config=config/server_${CONFIG}.cfg -port=$PORT -filePatching -enableHT -maxMem=12287 $MODS $SERVERMODS $PARAMS \
 1>>"/home/steam/test/log/arma3server_${NAME}_$(date +%s).rpt" 2>>"/home/steam/test/log/arma3server_${NAME}_$(date +%s).rpt"
# tail -f "/home/steam/test/log/arma3server_${NAME}_$(date +%s).rpt" | grep -v "base class"
