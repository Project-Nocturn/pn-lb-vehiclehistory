fx_version "cerulean"
game "gta5"

title "LB Phone - Vehicle History"
description "Historique d'entretien des véhicules via jg-mechanic"
author "Nocturn"

dependencies {
    'qb-core',
    'lb-phone',
    'oxmysql'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_script "client.lua"

file "ui/**/*"

ui_page "ui/index.html"
