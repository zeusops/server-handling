cd /home/steam/arma3

NAME=test2
PORT=2322
PROFILE=server_main
CONFIG=test2
PARAMS=-checkSignatures

. $HOME/bin/modscripts/finnisha.sh
# MODS=${MODS}\;mods/@name

. $HOME/bin/real_server.sh
