if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@cba_a3
MODS=${MODS}\;mods/@cup_terrain_core
MODS=${MODS}\;mods/@cup_terrain_cwa
MODS=${MODS}\;mods/@cup_terrain_maps
MODS=${MODS}\;mods/@rhsafrf			# AFRF
MODS=${MODS}\;mods/@rhsgref			# GREF
MODS=${MODS}\;mods/@rhsusaf			# USAF
MODS=${MODS}\;mods/@task_force_radio
MODS=${MODS}\;sideopmods/@esseker
MODS=${MODS}\;sideopmods/@ravage

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
