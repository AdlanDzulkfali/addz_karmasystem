fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'html/index.html'

server_script {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server.lua'
}

client_script {
	'config.lua',
	'client.lua'
}

files {
	'html/index.html',
	'html/assets/css/*.css',
	'html/assets/js/*.js',
	'html/assets/fonts/chineserocks/*.woff',
	'html/assets/images/*.png'
}
