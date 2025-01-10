fx_version 'cerulean'

game 'common'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'

-- -- use_experimental_fxv2_oal 'yes'

client_scripts{
	"data/horses_components.lua",
	"data/mp_overlay_layers.lua",
	"data/mp_peds_components.lua",
	"lib/utils.js",
	"lib/i18n.lua",
}

files {
    'library/linker.lua',
    'library/bootstrap.lua',
    'library/shared/**/*.lua',
    'library/client/**/*.lua',
    'library/server/**/*.lua',
    'library/server/*.lua',

    'library/client/prompt_builder.lua',

	"lib/*.lua",
}