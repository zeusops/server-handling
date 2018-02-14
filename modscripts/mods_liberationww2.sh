if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@cba_a3
MODS=${MODS}\;sideopmods/@faces_of_war
MODS=${MODS}\;sideopmods/@ifa3_aio_lite
MODS=${MODS}\;mods/@cup_terrain_core
MODS=${MODS}\;sideopmods/@ifa3_fow_compat
MODS=${MODS}\;mods/@task_force_radio

SERVERMODS="-serverMod="
SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
