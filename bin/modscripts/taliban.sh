if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@ericj_taliban
MODS=${MODS}\;mods/@rhsafrf			# AFRF
MODS=${MODS}\;mods/@rhsusaf			# USAF
MODS=${MODS}\;mods/@talibanrhs

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
