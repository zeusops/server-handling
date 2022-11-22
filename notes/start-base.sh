#!/bin/bash
if [ ${DEBUG:-no} = "yes" ]; then set -x; fi
set -euo pipefail

source ${BASE_PATH:-$HOME/server}/server-handling/bin/internal/environment.sh
# NOTE: path is relative to the arma3server location
readonly files_link=${FILES_LINK:-files}

usage() {
  (echo "Usage: $(basename $0) [--skip-init|--no-init] [--init] [--update-optional|--optional|--no-update-optional|--no-optional] [--perf|--no-perf] [--hc] [HCNAME] NAME [PORT]"
  echo "OPTIONS"
  echo "  --skip-init|--no-init               Skip initialization of the mods"
  echo "  --init                              Initialize the mods"
  echo "  --update-optional|--optional        Force updating optional mods"
  echo "  --no-update-optional|--no-optional  Do not update optional mods"
  echo "  --perf|--no-perf                    Enable or disable performance binary"
  echo "  --hc                                Create a headless client"
  echo "  HCNAME                              Name of the headless client"
  echo "  NAME                                Name of the server"
  echo "  PORT                                Port of the server"
  echo "Uses the environment variables A3_NAME and/or A3_PORT, if set") >&2
  exit 1
}

if [ ! -e "$base_path/link/available_keys/optional" ]; then
  update_optional=yes
else
  update_optional=no
fi
skip_init=no
hc=no
hc_name=unset
perf_mode=yes

argv=()
flags=()
while [ ${#} -gt 0 ]; do
  case "$1" in
    --skip-init|--no-init)
      skip_init=yes
      ;;
    --update-optional|--optional)
      update_optional=yes
      ;;
    --no-update-optional|--no-optional)
      update_optional=no
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
    --perf)
      perf_mode=yes
      ;;
    --no-perf)
      perf_mode=no
      ;;
    --port)
      if [ $# -gt 1 ]; then
        port="$2"; shift
      else
        echo "Error: found a --port parameter with no value"
        usage
      fi
      ;;
    --*)
      flags+=("$1")
    ;;
    *)
      argv+=("$1")
    ;;
  esac
  shift
done
# Restore unprocessed positional arguments
set -- "${argv[@]}"

readonly arg_name="${1:-}"; shift || true
readonly arg_port="${1:-}"; shift || true

# Restore unprocessed flags
set -- "$@" "${flags[@]}"
if [ $# -ne 0 ]; then
  echo "Unknown arguments: $@" >&2
  usage
fi

name=${arg_name-${A3_NAME-}}
# NOTE: This checks if the variable is either unset or empty. This is
#       intentional because setting the name to an empty value would
#       still be an error.
if [ -z "$name" ]; then
  echo "Missing server name" >&2
  usage
fi

file=$servers/${name}.sh
if [ ! -e "$file" ]; then
  echo "Server file ${name}.sh does not exist" >&2
  exit 1
fi
. $file

port=${arg_port:-${A3_PORT:-$PORT}}
if [ -z "$port" ]; then
  echo "Missing parameter PORT" >&2
  usage
fi
if [[ ! $port =~ ^[0-9]+$ ]]; then
  echo "Invalid port: $port" >&2
  usage
fi


echo "name: $name"
echo "port: $port"
echo "skip_init: $skip_init"
echo "hc: $hc"
echo "hc_name: $hc_name"

readonly profile=${PROFILE:-server}
readonly config=${CONFIG:-$name}
readonly params=${PARAMS:-}
readonly server_mods=${SERVERMODS:-}
readonly extra_mods=${EXTRAMODS:-}
readonly password=${PASSWORD:-}

if [ "$WINDOWS" = "yes" ]; then
  readonly config_path=$files_link\\config\\$config.cfg
  readonly basic_path=$files_link\\basic\\basic.cfg
else
  readonly config_path=$files_link/config/$config.cfg
  readonly basic_path=$files_link/basic/basic.cfg
fi

if [ "$skip_init" = "no" ]; then
  if [ "$update_optional" = "yes" ]; then
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
for x in $(find mods/$name -maxdepth 1 ! -path mods/$name); do
  dynamic_mods=${dynamic_mods}\;$x
done
# set -x
if [[ -n "$old_setting" ]]; then set -x; else set +x; fi
popd > /dev/null

readonly mods=${MODS:-$dynamic_mods}

echo "Launching with mods: $mods"
echo "Server name: $name, port: $port"

if [ "$PLATFORM" = "wsl" ]; then
  if [ "$perf_mode" = "yes" ]; then
    server=arma3server_x64_perf.exe
  else
    server=arma3server_x64.exe
  fi
else
  if [ "$perf_mode" = "yes" ]; then
    server=arma3server_x64_perf
  else
    server=arma3server_x64
  fi
fi

if [ "$hc" = "no" ]; then
  printf -v all_parameters "%s " \
    "-name=$profile" \
    "-profiles=profiles/server/" \
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
    "-cfg=$hc_name/basic.cfg" \
    "-profiles=profiles/hc/$hc_name" \
    "-port=$port" \
    "-password=$password" \
    "$mods;$extra_mods"
fi

cd $armadir
set -x
#echo \
$armadir/$server \
  $all_parameters
  #  >(tee -a $log_files/arma3server_${name}_$(date -Iseconds).stdout.log) 2> \
  #  >(tee -a $log_files/arma3server_${name}_$(date -Iseconds).stderr.log >&2)
  #-checkSignatures \
