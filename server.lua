local class = require "utils/class"
local weblit = require "weblit"
local Lobby = require "lobby"


local Server = class()

function Server:init()

	math.randomseed(os.time())

	self.lobby = Lobby()
end

function Server:run()

	local app = weblit.app
	app.bind {host = "0.0.0.0", port = 8080 }

	app.use(weblit.logger)
	app.use(weblit.autoHeaders)

	app.route({ path = "/" }, weblit.static("client"))

	app.websocket({ path = "/ws/:room" }, function(req, read, write)
		self.lobby:handleClient(req, read, write)
	end)

	app.start()
end

return Server
