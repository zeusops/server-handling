cd /home/steam/arma3

NAME=main
PORT=2302
PROFILE=server_main
CONFIG=main
PARAMS=""
# PARAMS="-checkSignatures"

. $HOME/bin/modscripts/mods.sh
# MODS=${MODS}\;mods/@name

. $HOME/bin/real_server.sh
