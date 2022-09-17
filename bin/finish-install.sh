#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh

readonly link=$base_path/link
readonly available_keys=$link/available_keys
readonly optional_keys=$link/optional_keys
readonly files_link=$armadir/files

for dir in workshop mpmissions available_keys logs mods optional_keys tmpmissions updated_keys userconfig; do
  if [ ! -L $armadir/$dir ]; then
    if [ -d $armadir/$dir ]; then
      if [ -f $armadir/$dir/readme.txt ]; then
        rm -v $armadir/$dir/readme.txt
      fi
      rmdir -v $armadir/$dir
    elif [ -e $armadir/$dir ]; then
      echo "$armadir/$dir exists"
      exit 1
    fi
    if [ ! -e $link/$dir ]; then
      mkdir -p $link/$dir
    fi
    ln -vs $(readlink -e $link/$dir) $armadir/$dir
  fi
done

if [ ! -L $files_link ]; then
  if [ -d $files_link ]; then
    rmdir -v $files_link
  elif [ -e $files_link ]; then
    echo "$files_link exists"
    exit 1
  fi
  ln -vs $(readlink -e $files) $files_link
fi

if [ ! -e $optional_keys/main ]; then
  ln -fvs $available_keys/optional $optional_keys/main
fi

if [ ! -e $link/workshop ]; then
  ln -fvs $install_dir/steamapps/workshop/content/107410 $link/workshop
fi
