#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh
# NOTE: path is relative to the arma3server location
readonly files_link=${FILES_LINK:-files}

name=${1-${A3_NAME-}}
if [ -z "${name}" ]; then
  echo "Usage: $(basename $0) NAME [PORT] --skip-init"
  echo "Uses the environment variables A3_NAME and/or A3_PORT, if set"
  exit 1
else
  file=$servers/${name}.sh
  if [ ! -e "$file" ]; then
    echo "Server file ${name}.sh does not exist"
    exit 1
  fi
  . $file
fi

port=${2-${A3_PORT:-$PORT}}

if [ -z "${port}" ]; then
  echo "Missing parameter PORT"
  exit 1
fi

if [ -n "${2:-}" ]; then
  skip_init=yes
fi

echo "name: $name"
echo "port: $port"

readonly profile=${PROFILE:-server}
readonly config=${CONFIG:-$name}
readonly params=${PARAMS:-}
readonly server_mods=${SERVERMODS:-}
readonly extra_mods=${EXTRAMODS:-}
if [ "$WINDOWS" = "yes" ]; then
  readonly config_path=$files_link\\config\\$config.cfg
  readonly basic_path=$files_link\\basic\\basic.cfg
else
  readonly config_path=$files_link/config/$config.cfg
  readonly basic_path=$files_link/basic/basic.cfg
fi

if [ "${skip_init:-no}" = "no" ]; then
  echo Updating optional mods
  update-mods.sh optional
  echo Updating server mods
  update-mods.sh $name

  echo Updating keys
  $bin/internal/keys.sh $name
  echo Key update done
fi

pushd $armadir > /dev/null
dynamic_mods="-mod="
old_setting=${-//[^x]/}
# set +x
for x in $(find mods/$name ! -path mods/$name); do
  dynamic_mods=${dynamic_mods}\;$x
done
# set -x
if [[ -n "$old_setting" ]]; then set -x; else set +x; fi
popd > /dev/null

readonly mods=${MODS:-$dynamic_mods}

echo "Launching with mods: $mods"
echo "Server name: $name, port: $port"

if [ "$PLATFORM" = "wsl" ]; then
  server=arma3server_x64.exe
else
  server=arma3server_x64
fi

set -x
#echo \
$armadir/$server \
  -name=$profile \
  -config=$config_path \
  -cfg=$basic_path \
  -port=$port \
  -filePatching \
  $mods\;$extra_mods $server_mods $params #> \
  #  >(tee -a $log_files/arma3server_${name}_$(date -Iseconds).stdout.log) 2> \
  #  >(tee -a $log_files/arma3server_${name}_$(date -Iseconds).stderr.log >&2)
  #-checkSignatures \
