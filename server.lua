local class = require "utils/class"
local weblit = require "weblit"
local Lobby = require "lobby"

local Server = class()

function Server:init()

	math.randomseed(os.time())

	self.lobby = Lobby()
	self.lobby:createRoom "test"
end

function Server:handleNew(req, res, go)

	local code = self.lobby:createRoom()

	res.code = 201
	res.body = code

	print("Room created", code)
end

function Server:run()

	local app = weblit.app
	app.bind {host = "0.0.0.0", port = 8080 }

	app.use(weblit.logger)
	app.use(weblit.autoHeaders)

	app.use(weblit.static("client"))

	app.route({ path = "/new", method = "GET" }, function(req, res, go)
		self:handleNew(req, res, go)
	end)

	app.websocket({ path = "/ws/:room" }, function(req, read, write)
		self.lobby:handleClient(req, read, write)
	end)

	app.start()
end

return Server
