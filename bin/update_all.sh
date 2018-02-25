set -e

MODIDS=$HOME/modids.txt
JOINTOPIDS=$HOME/jointopids.txt
STEAMDIR=$HOME/.steam/steamcmd
INSTALLDIR=$STEAMDIR/mods
ARMADIR=$HOME/arma3
MODS=$ARMADIR/mods
UPDATEDKEYS=$ARMADIR/updated_keys
JOINTOPKEYS=$HOME/test/arma3/available_keys/jointop
BACKUPMODS=$ARMADIR/backupmods
JOINTOPMODS=$HOME/test/arma3/mods/jointop

if [ "$1" == "--jointop" ]; then
	MODIDS=$JOINTOPIDS
        MODS=$JOINTOPMODS
        UPDATEDKEYS=$JOINTOPKEYS
fi


ALLMODS=""
while read line; do
	ARRAY=($line)
	MOD=${ARRAY[0]}
	ALLMODS="$ALLMODS +workshop_download_item 107410 $MOD"
done < $MODIDS

echo "Updating mods"
steamcmd +login zeusoperations +force_install_dir $INSTALLDIR $ALLMODS +quit
while read line; do
	ARRAY=($line)
	MODID=${ARRAY[0]}
	MODNAME=${ARRAY[1]}
	if [ -e $MODS/$MODNAME ]; then
		rm $MODS/$MODNAME
	fi
	ln -sv $INSTALLDIR/steamapps/workshop/content/107410/$MODID $MODS/$MODNAME
	lowercase_single.sh $MODS/$MODNAME/
	find $MODS/$MODNAME/ -type f -exec chmod -x {} \;
	find $MODS/$MODNAME/ -iname "*.bikey" -exec ln -sv {} $UPDATEDKEYS/ \;
done < $MODIDS
