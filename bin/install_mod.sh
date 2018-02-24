set -e

ARMADIR=$HOME/arma3
MODS=$ARMADIR/mods
STEAMDIR=$HOME/.steam/steamcmd
INSTALLDIR=$STEAMDIR/mods
UPDATEDKEYS=$ARMADIR/updated_keys
JOINTOPKEYS=$ARMADIR/jointop_keys
MODIDS=/home/steam/modids.txt
JOINTOPIDS=/home/steam/jointopids.txt
MODS=$ARMADIR/mods
SIDEOPMODS=$ARMADIR/sideopmods
JOINTOPMODS=$ARMADIR/jointopmods
BACKUPMODS=$ARMADIR/backupmods

if [ -z $2 ]; then
	echo "Usage: $0 --name modname | modid @modname [--side | --jointop]"
	exit
fi

cd $STEAMDIR
MODID="$1"
MODNAME="$2"

if [ "$1" == "--name" ]; then
	SEARCHNAME=$2
	ARRAY=($(grep $SEARCHNAME $MODIDS | head -n 1))
	MODID=${ARRAY[0]}
	MODNAME=${ARRAY[1]}
	echo "Interpreted $SEARCHNAME as $MODNAME with ID $MODID"
	read -s -p "Press enter to continue the installation or press ^C to abort"
	echo
fi

if [ "$3" == "--side" ]; then
	MODS=$SIDEOPMODS
fi

if [ "$3" == "--jointop"]; then
	MODS=$JOINTOPMODS
	UPDATEDKEYS=$JOINTOPKEYS
	MODIDS=$JOINTOPIDS
fi

echo "Downloading mod $MODNAME with ID $MODID"
./steamcmd.sh +login zeusoperations +force_install_dir $INSTALLDIR +workshop_download_item 107410 $MODID validate +quit
echo

if [ -e $MODS/$MODNAME ]; then
	if [ -L $MODS/$MODNAME ]; then
		rm $MODS/$MODNAME
	elif [ -f $MODS/$MODNAME ]; then
		echo "Existing mod is not a symbolic link. Backing up"
		mv -v $MODS/$MODNAME $BACKUPMODS/${MODNAME}_$(date +%Y%m%d-%m%S)
	else
		echo "$MODS/$MODNAME is unexpected type. Aborting"
		exit
	fi
fi

echo "Linking mod"
ln -s $INSTALLDIR/steamapps/workshop/content/107410/$MODID $MODS/$MODNAME
echo "Turning filenames into lowercase"
lowercase_single.sh $MODS/$MODNAME/
echo "Linking keys"
#mv -v $UPDATEDMODS/$MODNAME/*/*.bikey $UPDATEDKEYS
find $MODS/$MODNAME/ -iname "*.bikey" -exec ln -sv {} $UPDATEDKEYS/ \;
echo "Mod $MODNAME updated!"
#	echo "Mod files can be found in $UPDATEDMODS/$MODNAME"
echo "New or updated mod keys (if any) can be found in $UPDATEDKEYS"
