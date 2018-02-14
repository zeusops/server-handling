# 2018-01-23 Testing BE RCon

cd /home/steam/arma3

NAME=rcon
PORT=2322
PROFILE=server_main
CONFIG=rcon
PARAMS="-profiles=testprofiles"

MODS="-mod="

SERVERMODS="-serverMod="

# MODS=${MODS}\;mods/@name

. $HOME/bin/real_server.sh
