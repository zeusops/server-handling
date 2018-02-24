if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi
if [ ! -d /home/steam/test/arma3/mods/$NAME ]; then echo "/home/steam/test/arma3/mods/$NAME not found!"; exit 2; fi
MODS="-mod="

cd /home/steam/test/arma3/mods/

for x in $NAME/*; do
	MODS=${MODS}\;mods/$x
done

SERVERMODS="-serverMod="
