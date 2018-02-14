cd /home/steam/arma3

NAME=testsignatures
PORT=2322
PROFILE=server_main
CONFIG=testsignatures
PARAMS=-checkSignatures

. $HOME/bin/modscripts/testsignatures.sh
# MODS=${MODS}\;mods/@name

. $HOME/bin/real_server.sh
