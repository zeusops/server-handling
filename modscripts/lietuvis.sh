# start_arma3server_lietuvis.sh
# http://steamcommunity.com/groups/zeusoperations#events/1647625036713973159

if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@ace
MODS=${MODS}\;mods/@backpackonchest
MODS=${MODS}\;mods/@cba_a3
MODS=${MODS}\;mods/@cup_terrain_core
MODS=${MODS}\;mods/@cup_terrain_cwa
MODS=${MODS}\;mods/@cup_terrain_maps
MODS=${MODS}\;mods/@mrb_voicestop
MODS=${MODS}\;mods/@task_force_radio
MODS=${MODS}\;mods/@zeusops

MODS=${MODS}\;sideopmods/@ifa3_aio_lite
MODS=${MODS}\;sideopmods/@ifa3_liberation
MODS=${MODS}\;sideopmods/@ifa3_ace_compat

SERVERMODS="-serverMod="
