#!/bin/bash
set -x
set -euo pipefail

if [ "${1-}" == "-h" ] || [ "${1-}" == "--help" ]; then
  echo "Usage: $0 [-h|--help] MODSET";
  exit 1;
fi

modset=${1-main}

addons=$HOME/server/arma-addons
armadir=$HOME/server/arma3
mods=$HOME/link/mods/$modset

if [ ! -d $mods ]; then
  echo "Mod directory $mods not found"
  exit 1;
fi

function find_addons {
  cd $armadir
  find . -maxdepth 3 -name "*.pbo" -exec dirname {} \; | uniq | sed 's,^\./,,' | sed 's,/addons,,'
}

find $addons -type l -exec rm {} \;

for x in $(find_addons); do
  pushd $addons > /dev/null
  ln -s $(realpath --relative-to $addons $armadir)/$x
  popd > /dev/null
done
cd $addons
ln -s $HOME/link/mods/main
