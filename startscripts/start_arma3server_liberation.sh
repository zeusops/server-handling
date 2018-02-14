# 2017-10-12
# 2018-01-10
# [18:21] Irish: Would you be able to set up a liberation server again, we'd be looking at using these mods 

cd /home/steam/arma3

NAME=liber
PORT=2312
PROFILE=server_main
CONFIG=liber
PARAMS=

. $HOME/bin/modscripts/liberationmods.sh
# MODS=${MODS}\;mods/@name

. $HOME/bin/real_server.sh
