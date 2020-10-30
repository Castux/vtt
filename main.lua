package.path = './deps/?.lua;' .. package.path

local Server = require "server"

local server = Server(weblit)
server:run()
