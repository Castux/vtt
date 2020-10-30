package.path = './deps/?.lua;./client/?.lua;' .. package.path

local Server = require "server"

local server = Server()
server:run()
