# 2017-10-15 Insurgency

cd /home/steam/arma3

NAME=insurgency
PORT=2312
PROFILE=server_main
CONFIG=insurgency
PARAMS=

# . $HOME/bin/mods.sh
MODS="-mod="
MODS=${MODS}mods/@cba_a3
MODS=${MODS}\;mods/@task_force_radio
MODS=${MODS}\;sideopmods/@retex_aw101
MODS=${MODS}\;sideopmods/@retex_warrior
MODS=${MODS}\;sideopmods/@retex_wildcat
MODS=${MODS}\;mods/@cup_terrain_core
MODS=${MODS}\;mods/@3cb_baf_equipment
MODS=${MODS}\;mods/@3cb_baf_units
MODS=${MODS}\;mods/@3cb_baf_vehicles
MODS=${MODS}\;mods/@3cb_baf_weapons
MODS=${MODS}\;sideopmods/@ares
MODS=${MODS}\;sideopmods/@ai_rayak


. $HOME/bin/real_server.sh
