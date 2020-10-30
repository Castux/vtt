local js = require "js"

local function setup()

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
		editor.doc:setValue(ev.data)
	end

	ws.onerror = ws.onmessage
	ws.onclose = function(self, ev)
		editor.doc:setValue("Disconnected")
	end

	editor:on("blur", function()
		ws:send(editor.doc:getValue())
	end)
end


setup()
