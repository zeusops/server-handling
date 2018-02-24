if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/taliban/@rhsafrf
MODS=${MODS}\;mods/taliban/@rhsusaf
#MODS=${MODS}\;mods/taliban/@talibanrhs-gehock
MODS=${MODS}\;mods/taliban/@ericj_taliban_edit

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
