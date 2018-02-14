if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@ace
MODS=${MODS}\;mods/@ace_compat_rhsafrf		# RHS Compat AFRF
MODS=${MODS}\;mods/@ace_compat_rhsusaf		# RHS Compat USAF
MODS=${MODS}\;mods/@cba_a3
MODS=${MODS}\;mods/@cup_terrain_core
MODS=${MODS}\;mods/@cup_terrain_cwa
MODS=${MODS}\;mods/@cup_terrain_maps
MODS=${MODS}\;mods/@ericj_taliban
MODS=${MODS}\;mods/@mrb_voicestop
MODS=${MODS}\;mods/@rhsafrf
MODS=${MODS}\;mods/@rhsusaf
MODS=${MODS}\;mods/@task_force_radio
MODS=${MODS}\;mods/@zeusops_lite

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap
