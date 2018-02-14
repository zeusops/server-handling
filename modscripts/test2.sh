if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@rhsafrf
MODS=${MODS}\;mods/@rhsusaf
MODS=${MODS}\;mods/@ericj_taliban
MODS=${MODS}\;sideopmods/@talibanrhs-gehock

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
