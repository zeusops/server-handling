set -e

if [ -z $1 ]; then echo "Usage: `basename $0` servername [--test] [--skipdl]"; exit 1; fi

STEAMUSERNAME=zeusoperations

NAME=$1

BASEPATH=$HOME
if [ "$2" = "--test" ]; then BASEPATH=$HOME/test; fi
if [ "$2" = "--skipdl" ] || [ "$3" = "--skipdl" ]; then SKIPDOWNLOAD=yes; fi

MODIDS=$BASEPATH/files/modlists/${NAME}.txt
if [ ! -f $MODIDS ]; then echo "$MODIDS not found!"; exit 2; fi

STEAMDIR=$HOME/.steam/steamcmd
INSTALLDIR=$STEAMDIR/mods
ARMADIR=$BASEPATH/arma3
MODS=$ARMADIR/mods
export UPDATEDKEYS=$ARMADIR/updated_keys/$NAME
STEAMCMD=/usr/games/steamcmd
export AVAILABLEKEYS=$ARMADIR/available_keys/$NAME

function keys {
  key=$(basename "$1")
  if [ ! -f $AVAILABLEKEYS/$key ]; then
    ln -sv $1 $UPDATEDKEYS/$key
  fi
}

export -f keys

ALLMODS=""
while read line; do
  ARRAY=($line)
  # File format:
  # @modname 123456
  MODID=${ARRAY[1]}
  ALLMODS="$ALLMODS +workshop_download_item 107410 $MODID validate"
done < $MODIDS

if [ "$SKIPDOWNLOAD" != "yes" ]; then
  echo "Updating mods"
  $STEAMCMD +login $STEAMUSERNAME +force_install_dir $INSTALLDIR $ALLMODS +quit
  echo
else
  echo "Updating mod keys. This does not download updates"
fi

echo "Creating folders"
if [ ! -d $MODS/$NAME ]; then mkdir -p $MODS/$NAME; fi
if [ ! -d $UPDATEDKEYS ]; then mkdir -p $UPDATEDKEYS; fi
if [ ! -d $AVAILABLEKEYS ]; then mkdir -p $AVAILABLEKEYS; fi

echo "Removing old mod links"
find $MODS/$NAME -type l -exec rm {} \;
echo "Removing old key links"
find $UPDATEDKEYS -type l -exec rm {} \;

echo "Linking mods"
while read line; do
  ARRAY=($line)
  # File format:
  # @modname 123456
  MODNAME=${ARRAY[0]}
  MODID=${ARRAY[1]}
  MODPATH=$MODS/$NAME/$MODNAME
  if [ -e $MODPATH ]; then
    rm $MODPATH
  fi
  if [ ! -e $INSTALLDIR/steamapps/workshop/content/107410/$MODID ];
  then
    echo "$MODNAME with ID $MODID missing! Run `basename $0` $NAME"
    exit 1
  fi
  ln -sv $INSTALLDIR/steamapps/workshop/content/107410/$MODID $MODPATH
  if [ "$SKIPDOWNLOAD" != "yes" ]; then
    $BASEPATH/files/bin/internal/lowercase_single.sh $MODPATH/
  fi
  find $MODPATH/ -type f -exec chmod -x {} \;
  find $MODPATH/ -iname "*.bikey" -exec bash -c 'keys "$0"' {} \;
done < $MODIDS

echo "All mods updated. Following keys were updated:"
ls $UPDATEDKEYS
