set -e

if [ -z $1 ]; then echo "Usage: `basename $0` servername [--test] [--skipdl]"; exit 1; fi

readonly STEAMUSERNAME=zeusoperations

readonly NAME=$1

readonly BASEPATH=$HOME
if [ "$2" = "--test" ]; then BASEPATH=$HOME/test; fi
if [ "$2" = "--skipdl" ] || [ "$3" = "--skipdl" ]; then SKIPDOWNLOAD=yes; fi

readonly MODIDS=$BASEPATH/files/modlists/${NAME}.txt
if [ ! -f $MODIDS ]; then echo "$MODIDS not found!"; exit 2; fi

readonly STEAMDIR=$HOME/.steam/steamcmd
readonly INSTALLDIR=$STEAMDIR/mods
readonly ARMADIR=$BASEPATH/arma3
readonly MODS=$ARMADIR/mods
export UPDATEDKEYS=$ARMADIR/updated_keys/$NAME
readonly STEAMCMD=/usr/games/steamcmd
export AVAILABLEKEYS=$ARMADIR/available_keys/$NAME

function keys {
  key=$(basename "$1")
  if [ ! -f $AVAILABLEKEYS/$key ]; then
    ln -sv $1 $UPDATEDKEYS/$key
  fi
}

export -f keys

allmods=""
while read line; do
  array=($line)
  # File format:
  # @modname 123456
  modid=${array[1]}
  allmods="$allmods +workshop_download_item 107410 $modid validate"
done < $MODIDS

if [ "$SKIPDOWNLOAD" != "yes" ]; then
  echo "Updating mods"
  $STEAMCMD +login $STEAMUSERNAME +force_install_dir $INSTALLDIR $allmods +quit
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
  array=($line)
  # File format:
  # @modname 123456
  modname=${array[0]}
  modid=${array[1]}
  modpath=$MODS/$NAME/$modname
  if [ -e $modpath ]; then
    rm $modpath
  fi
  if [ ! -e $INSTALLDIR/steamapps/workshop/content/107410/$modid ];
  then
    echo "$modname with ID $modid missing! Run `basename $0` $NAME"
    exit 1
  fi
  ln -sv $INSTALLDIR/steamapps/workshop/content/107410/$modid $modpath
  if [ "$SKIPDOWNLOAD" != "yes" ]; then
    $BASEPATH/files/bin/internal/lowercase_single.sh $modpath/
  fi
  find $modpath/ -type f -exec chmod -x {} \;
  find $modpath/ -iname "*.bikey" -exec bash -c 'keys "$0"' {} \;
done < $MODIDS

echo "All mods updated. Following keys were updated:"
ls $UPDATEDKEYS
