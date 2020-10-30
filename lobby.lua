local class = require "utils/class"

local Lobby = class()

function Lobby:init()

	self.rooms = {}		-- rooms indexed by room code

end

local charset = "abcdefghijklmnopqrstuvwxyz0123456789"
local function generateCode()

	local code = ""
	for i = 1,6 do
		local index = math.random(#charset)
		code = code .. charset:sub(index,index)
	end
	return code
end

function Lobby:createRoom(code)

	if not code then
		repeat
			code = generateCode()
		until not self.rooms[code]
	end

	self.rooms[code] =
	{
		code = code,
		state = {},
		clients = {}	-- indexed by socket object
	}

	return code
end

function Lobby:broadcastToRoom(message, room)

	for _,client in pairs(room.clients) do

		client.write
		{
			opcode = 1,		-- text message
			payload = message
		}
	end
end

function Lobby:handleClient(req, read, write)

	local code = req.params.room
	local room = self.rooms[code]

	print("New client for room " .. code, req.socket)

	-- If room does not exist, disconnect client

	if not room then
		print("No such room", code)
		write()
		return
	end

	-- Otherwise, register them

	local client =
	{
		socket = req.socket,
		write = write
	}

	room.clients[req.socket] = client

	-- Start main listening loop

	for message in read do
		self:broadcastToRoom(message.payload, room)
	end

	-- Client disconnected, cleanup

	write()
	room.clients[req.socket] = nil
	print("Client disconnected from " .. code, req.socket)
end

return Lobby
