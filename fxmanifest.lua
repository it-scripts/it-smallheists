fx_version 'cerulean'
game 'gta5'

author 'Inseltreff'
description 'Rewritten version of qb-miniheists'

version '1.0.0'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/de.lua',
}


client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/*.lua'
}

server_scripts {
    'server/webhooks.lua',
    'server/main.lua',
}

dependencies {
    'qb-core',
    'PolyZone'
}

lua54 'yes'
usefxv2oal 'yes'
