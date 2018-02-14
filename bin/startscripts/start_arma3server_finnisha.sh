cd /home/steam/arma3

NAME=finnisha
PORT=2322
PROFILE=server_main
CONFIG=testsignatures
PARAMS=-checkSignatures

. $HOME/bin/modscripts/finnisha.sh
# MODS=${MODS}\;mods/@name

. $HOME/bin/real_server.sh
