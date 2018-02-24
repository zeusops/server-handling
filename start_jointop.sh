NAME=jointop
PORT=2312
PROFILE=server_main
CONFIG=jointop
PARAMS=

. $HOME/test/bin/keys.sh $NAME
. $HOME/test/bin/mods/${NAME}.sh
# MODS=${MODS}\;mods/@name

. $HOME/test/bin/real_server.sh
