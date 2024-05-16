fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

shared_scripts {
	"lib/utils.lua",
	"lib/i18n.lua",
	"lib/dataview.lua",
}

client_scripts{
	"data/horses_components.lua",
	"data/mp_overlay_layers.lua",
	"data/mp_peds_components.lua",
	"lib/utils.js",
}

files {
	"lib/utils.lua",
	"lib/Tunnel.lua",
	"lib/Proxy.lua",
	"lib/Tools.lua",
}

lua54 'yes'