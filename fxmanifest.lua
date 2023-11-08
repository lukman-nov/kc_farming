fx_version  'adamant'
game 			  'gta5'
lua54 		  'yes'

author 			'Lukman_Nov#5797'
description 'Farming Sidejob by Kucluck Script'
version 		'1.0.0'
license    	'GNU General Public License v3.0'

shared_scripts {
	'@ox_lib/init.lua',
  'locales.lua',
	'locale/*.lua',
	'config.lua',
}

server_scripts {
  "@mysql-async/lib/MySQL.lua",
	'bridge/**/server.lua',
	'server/main.lua'
}

client_scripts {
	'bridge/**/client.lua',
	'client/main.lua',
}