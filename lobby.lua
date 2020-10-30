local class = require "utils/class"
local diff = require "utils/diff"
local json = require "json"

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

function Lobby:broadcastToRoom(room, payload)

	for _,client in pairs(room.clients) do

		client.send(payload)
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
	-- Wrap the sender function for convenience

	local client =
	{
		socket = req.socket,
		send = function(payload)
			write
			{
				opcode = 1,
				payload = json.encode(payload)
			}
		end
	}

	room.clients[req.socket] = client

	-- Send them the current room state

	client.send(room.state)

	-- Start main listening loop

	for message in read do
		local payload = json.decode(message.payload)
		self:handleMessage(room, client, payload)
	end

	-- Client disconnected, cleanup

	write()
	room.clients[req.socket] = nil
	print("Client disconnected from " .. code, req.socket)
end

function Lobby:handleMessage(room, client, payload)

	p(room.code, client.socket, payload)

	-- Apply message to room as diff
	diff.patch(room.state, payload)

	p("New state", room.state)

	-- Broadcast the changes
	self:broadcastToRoom(room, payload)
end

return Lobby
