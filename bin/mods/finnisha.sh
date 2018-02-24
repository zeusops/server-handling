if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/finnisha/@cba_a3
MODS=${MODS}\;mods/finnisha/@project_infinite
MODS=${MODS}\;mods/finnisha/@test_3

SERVERMODS="-serverMod="
#SERVERMODS=${SERVERMODS}mods/@ocap

#export MODS
