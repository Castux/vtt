local sockets = {}

local weblit = require "weblit"
local json = require "json"

local app = weblit.app
app.bind {host = "0.0.0.0", port = 8080 }

app.use(weblit.logger)
app.use(weblit.autoHeaders)

app.route({ path = "/" }, weblit.static("client"))

local function socketHandler (req, read, write)

    print("New client")
    sockets[req.socket] = function(str)
        write({
            opcode = 1,
            payload = str
        })
    end

    for message in read do

        print("Got:", message.payload)

        for sock,writer in pairs(sockets) do
            if sock ~= req.socket then
                writer(message.payload .. " back")
            end
        end
    end

    write()
    print("Client left")
    sockets[req.socket] = nil
end

app.websocket({ path = "/ws" }, socketHandler)
app.start()
