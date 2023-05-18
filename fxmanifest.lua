fx_version 'adamant'

game 'gta5'

author 'Lukman_Nov#5797'
description 'Farming Sidejob ESX Legacy'
lua54 'yes'
version '1.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

server_scripts {
  "@mysql-async/lib/MySQL.lua",
	'server/main.lua'
}

client_scripts {
	'client/main.lua',
}