fx_version 'adamant'
game 'gta5'
lua54 'yes'
author 'ENT510'
version '1.0.0'

shared_scripts {
    "@ox_lib/init.lua",
    "@LGF_Utility/init.lua",
    "init.lua",
    "shared/config.lua",
    "shared/items.lua",
    "shared/shared.lua",
}

client_scripts {
    "bridge/**/cl-bridge.lua",
    "modules/client/**/*.lua"
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "bridge/**/sv-bridge.lua",
    "modules/server/*.lua",

}


files { 'web/build/index.html', 'web/build/**/*', "web/images/*.png", }
ui_page 'web/build/index.html'
