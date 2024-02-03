fx_version 'adamant'
games { 'gta5' }

shared_script 'config.lua'

server_scripts {"server.lua"}
client_scripts {"client.lua"}

ui_page_preload "yes"
ui_page "web/index.html"

files {
    "web/index.html",
    "web/script.js",
    "web/style.css"
}