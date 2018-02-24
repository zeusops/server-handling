NAME=retex
PORT=2322
PROFILE=server_main
CONFIG=signature
PARAMS=-checkSignatures

. $HOME/test/bin/keys.sh $NAME
. $HOME/test/bin/mods/${NAME}.sh
# MODS=${MODS}\;mods/@name

. $HOME/test/bin/real_server.sh
