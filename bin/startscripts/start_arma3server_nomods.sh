# 2017-11-21 Sif introducing a friend
# 2018-01-17 <22:21:29> "2LT D. Irish": would you be able to put this mission file on the server, https://steamcommunity.com/sharedfiles/filedetails/?id=1269676284 its vanilla nd is made by one of the UNA guys

cd /home/steam/arma3

NAME=nomods
PORT=2322
PROFILE=server_main
CONFIG=nomods
PARAMS=

MODS="-mod="

SERVERMODS="-serverMod="

# MODS=${MODS}\;mods/@name

. $HOME/files/bin/real_server.sh
