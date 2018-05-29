set -e

MODLISTS=$HOME/files/modlists
ALLMODIDS=/tmp/modids.txt
STEAMDIR=$HOME/.steam/steamcmd
INSTALLDIR=$STEAMDIR/mods
#ARMADIR=$HOME/arma3
#MODS=$ARMADIR/mods
#UPDATEDKEYS=$ARMADIR/updated_keys
#BACKUPMODS=$ARMADIR/backupmods
STEAMCMD=/usr/games/steamcmd
LOWERCASE=$HOME/files/bin/internal/lowercase_single.sh

sort $MODLISTS/* -u > $ALLMODIDS

ALLMODS=""
while read line; do
	ARRAY=($line)
	MOD=${ARRAY[0]}
	ALLMODS="$ALLMODS +workshop_download_item 107410 $MOD"
done < $ALLMODIDS

echo $ALLMODS
echo $INSTALLDIR

echo "Updating mods"
$STEAMCMD +login zeusoperations +force_install_dir $INSTALLDIR $ALLMODS +quit

while read line; do
	ARRAY=($line)
	MODID=${ARRAY[0]}
#	MODNAME=${ARRAY[1]}
#	if [ -e $MODS/$MODNAME ]; then
#		rm $MODS/$MODNAME
#	fi
#	ln -sv $INSTALLDIR/steamapps/workshop/content/107410/$MODID $MODS/$MODNAME
	$LOWERCASE $INSTALLDIR/steamapps/workshop/content/107410/$MODID
#	find $MODS/$MODNAME/ -type f -exec chmod -x {} \;
#	find $MODS/$MODNAME/ -iname "*.bikey" -exec ln -sv {} $UPDATEDKEYS/ \;
done < $ALLMODIDS

rm $ALLMODIDS
