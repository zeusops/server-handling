if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi

MODS="-mod="
MODS=${MODS}mods/@cba_a3
MODS=${MODS}\;mods/@rhsafrf			# AFRF
MODS=${MODS}\;mods/@rhsgref			# GREF
MODS=${MODS}\;mods/@rhssaf			# SAF
MODS=${MODS}\;mods/@rhsusaf			# USAF
MODS=${MODS}\;mods/@tfar_beta
MODS=${MODS}\;sideopmods/@stui
