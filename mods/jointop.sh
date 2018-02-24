if [ -z $NAME ]; then echo "Not to be run directly"; exit 1; fi


MODS="-mod="
MODS=${MODS}mods/main/@3cb_baf_equipment
MODS=${MODS}\;mods/main/@3cb_baf_units
MODS=${MODS}\;mods/main/@3cb_baf_vehicles
MODS=${MODS}\;mods/main/@3cb_baf_weapons
MODS=${MODS}\;mods/main/@2035_rf
MODS=${MODS}\;mods/main/@ace
MODS=${MODS}\;mods/main/@ace_compat_rhsafrf
MODS=${MODS}\;mods/main/@ace_compat_rhsgref
MODS=${MODS}\;mods/main/@ace_compat_rhsusaf
MODS=${MODS}\;mods/main/@advanced_rappelling
MODS=${MODS}\;mods/main/@advanced_slingloading
MODS=${MODS}\;mods/main/@armaretex_caboose
MODS=${MODS}\;mods/main/@backpackonchest
MODS=${MODS}\;mods/main/@cba_a3
MODS=${MODS}\;mods/main/@cup_terrain_core
MODS=${MODS}\;mods/main/@cup_terrain_cwa
MODS=${MODS}\;mods/main/@cup_terrain_maps
MODS=${MODS}\;mods/main/@fallujah
MODS=${MODS}\;mods/main/@ericj_taliban
MODS=${MODS}\;mods/main/@hamf_helicopters
MODS=${MODS}\;mods/main/@hamf_navy
MODS=${MODS}\;mods/main/@isla_abramia
MODS=${MODS}\;mods/main/@isla_duala
MODS=${MODS}\;mods/main/@island_panthera
MODS=${MODS}\;mods/main/@mrb_voicestop               # Voice stop for clients
MODS=${MODS}\;mods/main/@project_infinite
MODS=${MODS}\;mods/main/@rhsafrf                     # AFRF
MODS=${MODS}\;mods/main/@rhsgref                     # GREF
MODS=${MODS}\;mods/main/@rhssaf                      # SAF
MODS=${MODS}\;mods/main/@rhsusaf                     # USAF
MODS=${MODS}\;mods/main/@task_force_radio
MODS=${MODS}\;mods/main/@tembelan_island
MODS=${MODS}\;mods/main/@zeusops_edit
MODS=${MODS}\;mods/taliban/@talibanrhs-gehock


SERVERMODS="-serverMod="
