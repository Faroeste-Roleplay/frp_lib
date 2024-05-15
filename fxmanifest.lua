fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

shared_scripts {
	"lib/utils.lua",
	"modules/utils/i18n.lua",
	"modules/utils/dataview.lua",
}

client_scripts{
	"modules/_main.lua",
	"data/horses_components.lua",
	"data/mp_overlay_layers.lua",
	"data/mp_peds_components.lua",

	"modules/appearance/constants.lua",
	"modules/appearance/overlays.lua",
	"modules/appearance/main.lua",
	"modules/appearance/apparatusDatabase.lua",
	"modules/appearance/applyPersonaAppearance.lua",
	"modules/appearance/clothingSystemResolvers.lua",
	"modules/appearance/utils.lua",
	"modules/appearance/utils.js",
}

files {
	"lib/utils.lua",
	"lib/Tunnel.lua",
	"lib/Proxy.lua",
	"lib/Tools.lua",
}

lua54 'yes'