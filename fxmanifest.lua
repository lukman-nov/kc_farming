fx_version 'adamant'

game 'gta5'

author 'Lukman_Nov#5797'
description 'Farming Sidejob'
lua54 'yes'
version '1.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'@es_extended/locale.lua',
	'locales/*.lua'
}

server_scripts {
	'server/main.lua',
	'config.lua',
}

client_scripts {
	'client/main.lua',
	'config.lua',
}

dependencies {
  'ox_lib'
}