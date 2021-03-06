#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/files/bin/internal/environment.sh
# NOTE: path is relative to the arma3server location
readonly files_link=${FILES_LINK:-files}

usage() {
  echo "Usage: $(basename $0) [--skip-init|--no-init] [--init] [--update-optional|--optional] [--hc] [hc1] NAME [PORT]"
  echo "Uses the environment variables A3_NAME and/or A3_PORT, if set"
  exit 1
}

while [ ${#} -gt 0 ]; do
  case "$1" in
    --skip-init|--no-init)
      skip_init=yes
      ;;
    --update-optional|--optional)
      update_optional=yes
      ;;
    --hc)
      hc=yes
      skip_init=yes
      if [ $# -gt 1 ] && [[ ${2:-} != --* ]]; then
        hc_name="$2"; shift
      else
        hc_name="hc1"
      fi
      ;;
    --init|--force-init)
      skip_init=no
      ;;
    --port)
      if [ $# -gt 1 ]; then
        port="$2"; shift
      else
        echo "Error: found a --port parameter with no value"
        usage
      fi
      ;;
    *)
      # NOTE: This checks if the variable is either unset or empty. This is
      #       intentional because setting the name (or port) to an empty value
      #       would still be an error.
      if [ -z "${arg_name:-}" ]; then
        arg_name="$1"
      elif [ -z "${arg_port:-}" ]; then
        if [[ $1 =~ ^[0-9]+$ ]]; then
          arg_port="$1"
        else
          echo "Invalid port: $1"
          usage
        fi
      else
        echo "Unknown argument: $1"
      fi
      ;;
  esac
  shift
done

name=${arg_name-${A3_NAME-}}
if [ -z "$name" ]; then
  usage
else
  file=$servers/${name}.sh
  if [ ! -e "$file" ]; then
    echo "Server file ${name}.sh does not exist"
    exit 1
  fi
  . $file
fi

port=${arg_port-${A3_PORT:-$PORT}}

if [ -z "${port}" ]; then
  echo "Missing parameter PORT"
  exit 1
fi

echo "name: $name"
echo "port: $port"
echo "skip_init: ${skip_init:-no}"
echo "hc: ${hc:-no}"
echo "hc_name: ${hc_name:-unset}"

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
  if [ "${update_optional:-no}" = "yes" ]; then
    echo Updating optional mods
    update-mods.sh optional
  fi
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
  server=arma3server_x64_perf.exe
  #server=arma3server_x64.exe
else
  server=arma3server_x64_perf
  #server=arma3server_x64
fi

if [ "${hc:-no}" = "no" ]; then
  printf -v all_parameters "%s " \
    "-name=$profile" \
    "-config=$config_path" \
    "-cfg=$basic_path" \
    "-port=$port" \
    "-filePatching" \
    "$mods;$extra_mods" \
    "$server_mods $params"
else
  printf -v all_parameters "%s " \
    "-name=$hc_name" \
    "-client" \
    "-connect=127.0.0.1" \
    "-profiles=$hc_name" \
    "-port=$port" \
    "$mods\;$extra_mods"
fi

set -x
#echo \
$armadir/$server \
  $all_parameters
  #  >(tee -a $log_files/arma3server_${name}_$(date -Iseconds).stdout.log) 2> \
  #  >(tee -a $log_files/arma3server_${name}_$(date -Iseconds).stderr.log >&2)
  #-checkSignatures \
