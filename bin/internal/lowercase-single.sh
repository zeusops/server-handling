#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

if [ -z ${1-} ]
then
  echo "Usage: $(basename $0) path"
  exit 1
fi

if [ ${WINDOWS:-no} = "no" ]; then
  find $1 -depth -print0 | xargs -0 -n1 rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
fi
