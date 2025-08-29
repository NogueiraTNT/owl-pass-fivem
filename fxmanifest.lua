fx_version 'bodacious'
game 'gta5'

dependencies {
	'vrp',
}

ui_page 'ui/index.html'

client_scripts {
	"@vrp/lib/utils.lua",
    'config/*.lua',
    'client/*.lua'
}

server_scripts {
	"@vrp/lib/utils.lua",
    'config/*.lua',
    'server/*.lua'
}


files {
    'ui/index.html',
    'ui/style.css',
    'ui/modal.css',
    'ui/atm.css',
    'ui/script.js'
}
