if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/retex/@cba_a3
MODS=${MODS}\;mods/retex/@armaretex_resign
MODS=${MODS}\;mods/retex/@project_infinite
MODS=${MODS}\;mods/retex/@rhsafrf
MODS=${MODS}\;mods/retex/@rhsgref
MODS=${MODS}\;mods/retex/@rhssaf
MODS=${MODS}\;mods/retex/@rhsusaf

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
