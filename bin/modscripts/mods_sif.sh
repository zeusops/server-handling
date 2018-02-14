if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@cba_a3
MODS=${MODS}\;mods/@cup_terrain_core
MODS=${MODS}\;sideopmods/@ifa3_aio_lite
MODS=${MODS}\;sideopmods/@faces_of_war

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
