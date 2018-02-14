# 2017-12-25
# [01:13] SifTheAI: You able to set up a new command line for the server? Mods that are needed are already on it.

cd /home/steam/arma3

NAME=sif
PORT=2312
PROFILE=server_main
CONFIG=custom
PARAMS=

. $HOME/bin/modscripts/mods_sif.sh
# MODS=${MODS}\;mods/@name

. $HOME/bin/real_server.sh
