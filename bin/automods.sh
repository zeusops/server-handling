if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi
if [ -z $BASEPATH ]; then echo "Not to be run directly"; exit 1; fi
if [ ! -d $BASEPATH/arma3/mods/$NAME ]; then echo "$BASEPATH/arma3/mods/$NAME not found!"; exit 2; fi
MODS="-mod="

cd $BASEPATH/arma3/mods/

for x in $NAME/*; do
	MODS=${MODS}\;mods/$x
done

SERVERMODS="-serverMod="
