#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh

name=${1-${NAME:-${name-}}}
if [ -z "$name" ]; then
	echo "Usage: $(basename $0) MODNAME"
	exit 1
fi

if [ ! -d "$armadir/available_keys" ]; then
  echo "Missing folder $armadir/available_keys. Setup is incomplete!"
  echo "Make sure that the Arma server is installed and run finish-install.sh to complete the setup."
  exit 2
fi

if [ ! -d "$armadir/available_keys/$name" ]; then
	echo "Folder $armadir/available_keys/$name not found!"
	exit 3
fi

# Directory structure:
# arma3
# ├── available_keys
# │   └── $name
# │       └── keyname.bikey ->

function relpath {
  if [ -L "$1" ]; then
    target_path=$(dirname "$1")
    target=$target_path/$(readlink "$1")
  else
    target="$1"
  fi
  dir=${2:-.}
  # >&2 echo all $@
  # >&2 echo target, dir: $target $dir
  # >&2 echo readlink $(readlink "$1")
  # >&2 echo realpath dir $(realpath $dir)
  path=$(python3 -c "import os; print(os.path.relpath(\"$target\", \"$dir\"))")
  # >&2 echo py relpath: $path
  #exit 1
  echo $path
}

keypath=$armadir/keys
# The keys directory should usually exist already but creating just in case
mkdir -p $keypath
pushd $keypath > /dev/null
# Remove old keys
find . -type l -exec rm {} \;

if [ ! -e a3.bikey ]; then
  ln -sf ../available_keys/a3.bikey
fi

if [ ! -e ../optional_keys/$name ]; then
  ln -sf main ../optional_keys/$name
fi

for dir in ../available_keys/$name ../optional_keys/$name; do
  # echo "dir1 $dir"
  if [ -e "$dir" ]; then
    # echo "dir2 $dir"
    # Requires the trailing slash if $dir is a symlink
    for key in $(find $dir/ -xtype f); do
      # echo "key $key"
      if [ -L $key ]; then
        target=$(relpath $key)
      else
        target=$key
      fi
      ln -sf $key
    done
  fi
done

popd > /dev/null
