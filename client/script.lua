local js = require "js"
local diff = require "utils/diff"
local json = require "json"

local function setup()

	local roomState = {}

	local textArea = js.global.document:getElementById "code"
	local editor = js.global.CodeMirror:fromTextArea(
		textArea,
		{
			lineNumbers = true,
			mode = {name = "javascript", json = true},
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
		print(payload)

		diff.patch(roomState, payload)

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
		
		local payload = diff.diff(roomState, new)

		ws:send(json.encode(payload))
	end)
end


setup()
