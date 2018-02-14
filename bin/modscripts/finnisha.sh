if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@cba_a3
MODS=${MODS}\;sideopmods/@test_2
MODS=${MODS}\;mods/@project_infinite

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
