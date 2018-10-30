NAME=elections
PORT=2302

PROFILE=  # default: server
CONFIG=elections  # default: $NAME
PARAMS='-checkSignatures'

# Uncomment to prevent automatic key updates
# NOKEYS=on

SERVERMODS=-serverMod=mods/cntr/@cntr

# Uncomment to prevent automatic mod detection based on $NAME
# MODS=-mod=mods/@name
