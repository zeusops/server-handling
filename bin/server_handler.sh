#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

BASEPATH=$HOME
BIN=$BASEPATH/files/bin
PIDFILES=$BASEPATH/files/run
SERVERADDRESS=arma.zeusops.com
SERVERINFO=$BIN/internal/serverinfo.py

### Exit codes:
## start:
##   1  already running
##   2  not installed
##   3  not executable
##   4  could not start
##   11 mods missing
## stop:
##   5  pidfile missing
## list:
##   0  available servers
## info:
##   0  info + status
## common:
##   6  no config file
##   7  server name mismatch
##   8  usage
## status:
##   9  server died
##   10 not running


do_usage() {
  echo "Usage: $(basename $0) --list | --list-all | servername {stop|status|restart|log|info|start [ --log ]}" >&2
}

do_start() {
  if [ -e $PIDFILE ]; then
    PID=$(cat $PIDFILE)
    if (kill -0 $PID 2> /dev/null); then
      >&2 echo "Server $NAME is already running with PID $PID, see restart, status and stop."
      exit 1
    else
      >&2 echo "Server $NAME not running but pidfile found, server has probably died."
      rm $PIDFILE
    fi
  fi

  # Mods might've already been defined in SERVERFILE file
  if [ -z $MODS ]; then
    # Relink mod folders without downloading updates
    if ! $BIN/update_mods.sh $NAME --skipdl; then
      exit 11
    fi

    pushd $BASEPATH/arma3/mods/ > /dev/null
    MODS="-mod="
    for x in $NAME/*; do
      MODS=${MODS}\;mods/$x
    done
    popd > /dev/null
  fi

  if [ -z $NOKEYS ]; then . $BIN/internal/keys.sh; fi

  CONFIGPATH=$BASEPATH/files/config/${CONFIG}.cfg
  LOGPATH=$BASEPATH/log/
  if [ ! -d $LOGPATH ]; then mkdir -p $LOGPATH; fi

  if [ ! -d $BASEPATH/arma3 ]; then
    >&2 echo "Arma 3 server not installed"
    exit 2
  fi
  if [ ! -e $BASEPATH/arma3/arma3server ]; then
    >&2 echo "Arma 3 server not executable"
    exit 3
  fi
  cd $BASEPATH/arma3

  echo "Starting server $NAME on $(date) on port $PORT"
  ./arma3server   -name=$PROFILE \
                  -config=$CONFIGPATH \
                  -port=$PORT \
                  -filePatching \
                  $MODS $SERVERMODS $PARAMS \
                  1>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt" \
                  2>>"$LOGPATH/${NAME}_$(date +%F_%H-%M-%S).rpt" &
  PID=$!
  kill -0 $PID > /dev/null
  if [ $? -ne 0 ]; then
    >&2 echo "Could not start the server"
    exit 4
  else
    echo $PID > $PIDFILE
    if [ ! -z $SHOW_LOG ]; then
      echo "Server started."
      sleep 1
      do_log
    else
      echo "Server started. View the logfile with parameter 'log'"
    fi
  fi
}

do_stop() {
  if [ ! -e $PIDFILE ]; then
    >&2 echo "Pidfile missing, server not running"
    exit 5
  fi
  echo -n "Stopping server $NAME"
  if ( kill -INT $(cat $PIDFILE) 2> /dev/null ); then
    i=1
    while [ "$i" -le 10 ]; do
    if ( kill -0 $(cat $PIDFILE) 2> /dev/null) ; then
      echo -n "."
      sleep 1
    else
      break
    fi
    ((i++))
    done
  fi
  if ( kill -0 $(cat $PIDFILE) 2> /dev/null) ; then
    echo
    echo "Killing server"
    kill -KILL $(cat $PIDFILE)
  else
    echo
    echo "Done"
  fi
  rm $PIDFILE
}

do_restart() {
  echo "Restarting server $NAME"
  do_stop
  do_start
}

do_status() {
  if [ -e $PIDFILE ]; then
    PID=$(cat $PIDFILE)
    if (kill -0 $PID 2> /dev/null); then
      echo "Server $NAME is running. (PID $(cat $PIDFILE))"  # TODO: Player count / serverinfo
    else
      >&2 echo "Server $NAME not running but pidfile found, server has probably died."
      rm $PIDFILE
      exit 9
    fi
  else
    >&2 echo "Server $NAME is not running."
    exit 10
  fi
}

do_list() {
  echo "Running servers:"
  for f in $PIDFILES/*.pid; do
    NAME=$(echo $(basename $f) | sed 's/.pid//')
    if $0 $NAME status &> /dev/null; then
      PORT=$($0 $NAME get-port)
      QUERYPORT=$((++PORT))
      PLAYERS=$($SERVERINFO $SERVERADDRESS $QUERYPORT --players)
      echo "Port: $PORT | PID: $(cat $f) | Players: $PLAYERS | Name: $NAME"
    fi
  done
}

do_list_all() {
  echo "Available servers:"
  find $BASEPATH/files/servers -name "*.sh" -exec bash -c 'servername "$0"' {} \;
}

do_info() {
  QUERYPORT=$((++PORT))
  INFO=$($SERVERINFO $SERVERADDRESS $QUERYPORT)
  echo "Info about server $NAME:"
  echo $INFO
  echo "Port: $PORT"
  echo "Profile: $PROFILE"
  echo "Config: $CONFIG"

  if [ ! -z $PARAMS ]; then
    echo "Custom parameters: $PARAMS"
  fi
  if [ -z $MODS ]; then
    echo "Mods: autodetect"
  else
    echo "Mods: $MODS"
  fi
  if [ ! -z $SERVERMODS ]; then
    echo "Server-side mods: $SERVERMODS"
  fi
  if [ -z $NOKEYS ]; then
    echo "Automatic key updating enabled"
  else
    echo "Automatic key updating disabled"
  fi
  do_status
}

do_log() {
  FILE=$(ls -1 $BASEPATH/log/${NAME}_*.rpt | tail -n 1)
  FILENAME=$(echo $FILE | sed "s|$BASEPATH/log/||")
  echo "Showing log file $FILENAME. Exit log with ^C."
  echo
  echo
  trap cleanup INT
  tail -f $FILE
}

function servername {
  SRV=$(basename $1)
  echo $SRV | sed 's/.sh//'
}
export -f servername


function cleanup {
  echo
  echo
  echo "Exiting log. This does not kill the server. Stop the server with: $(basename $0) $NAME stop"
  exit 0
}

function confirm {
  while :; do
    read -t10 -p "Are you sure you want to $1 the server? (y/N): "
    case $REPLY in
      [yY]*)
        echo "Continuing"
        return
        ;;
      [nN]*|*)
        echo "Canceling"
        exit 0
        ;;
    esac
  done
}

if [ $# -gt 1 ]; then
  SERVERNAME=$1
  PIDFILE=$PIDFILES/$SERVERNAME.pid

  SERVERFILE=$BASEPATH/files/servers/$SERVERNAME.sh
  if [ -e $SERVERFILE ]; then
    . $SERVERFILE
  else
    >&2 echo "No config file found for server $SERVERNAME."
    exit 6
  fi
  if [ $SERVERNAME != $NAME ]; then
    >&2 echo "Server name $NAME in file $SERVERFILE does not match given name $SERVERNAME"
    exit 7
  fi

  if [ -z $PROFILE ]; then PROFILE=server; fi
  if [ -z $CONFIG ]; then CONFIG=$NAME; fi

  if [ "$3" = "--log" ]; then SHOW_LOG=yes; fi
else
  case "$1" in
    --list)
      do_list
    ;;
    --list-all)
      do_list_all
    ;;
    *)
      do_usage
      exit 8
    ;;
  esac
  exit 0
fi

case "$2" in
  start)
    do_start
  ;;
  stop)
    confirm "stop"
    do_stop
  ;;
  status)
    do_status
    exit 0
  ;;
  restart)
    confirm "restart"
    do_restart
  ;;
  info)
    do_info
    exit 0
  ;;
  log)
    do_log
  ;;
  get-port)
    echo -n $PORT
  ;;
  *)
    do_usage
    exit 8
  ;;
esac
exit 0
