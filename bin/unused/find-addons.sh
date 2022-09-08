#!/bin/bash

set -euo pipefail

cd $HOME/server/arma3
find . -maxdepth 3 -name "*.pbo" -exec dirname {} \; | uniq | sed 's,^\./,,' | sed 's,/addons,,'
