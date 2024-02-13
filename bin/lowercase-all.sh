#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh

echo "Renaming"

echo "$workshop"

if [ ${WINDOWS:-no} = "no" ]; then
  find "$workshop"/. -depth -name "*[A-Z]*" -print0 | xargs -0 -n1 rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
fi

echo "Rename done"
