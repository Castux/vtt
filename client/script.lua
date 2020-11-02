local js = require "js"
local diff = require "utils/diff"
local json = require "json"

local function Object(t)
	local o = js.new(js.global.Object)
	for k, v in pairs(t) do
		assert(type(k) == "string" or js.typeof(k) == "symbol", "JavaScript only has string and symbol keys")
		o[k] = v
	end
	return o
end

local function setup()

	local roomStateId = nil
	local roomState = {}

	local textArea = js.global.document:getElementById "code"
	local editor = js.global.CodeMirror:fromTextArea(
		textArea,
		Object {
			lineNumbers = true,
			mode = Object { name = "javascript", json = true },
			indentWithTabs = true,
			indentUnit = 4,
			lineWrapping = true
		}
	)

	local ws = js.new(js.global.WebSocket, "ws://127.0.0.1:8080/ws/test")

	ws.onopen = function(self, ev)
		editor.doc:setValue("Connected")
	end

	ws.onmessage = function(self, ev)

		local payload = json.decode(ev.data)

		if payload.op == "full" then
			roomStateId = payload.id
			roomState = payload.state
		elseif payload.op == "patch" then
			roomStateId = payload.id
			diff.patch(roomState, payload.diff)
		end

		editor.doc:setValue(json.encode(roomState))
	end

	ws.onerror = ws.onmessage
	ws.onclose = function(self, ev)
		editor.doc:setValue("Disconnected")
	end

	editor:on("blur", function()

		local new = json.decode(editor.doc:getValue())

		if not new then
			editor.doc:setValue(json.encode(roomState))
			return
		end

		local payload =
		{
			id = roomStateId,
			diff = diff.diff(roomState, new)
		}
		
		ws:send(json.encode(payload))
	end)
end


setup()
