function setup()
{
	var myTextarea = document.getElementById("code");
	editor = CodeMirror.fromTextArea(myTextarea, {
		lineNumbers: true,
		mode: {name: "javascript", json: true},
		indentWithTabs: true,
		indentUnit: 4,
		lineWrapping: true
	});

	var ws = new WebSocket("ws://127.0.0.1:8080/ws/test");

	ws.onopen = function(ev)
	{
		editor.doc.setValue("Connected");
	}

	ws.onmessage = function(ev)
	{
		editor.doc.setValue(ev.data);
	}

	ws.onerror = ws.onmessage;
	ws.onclose = function(ev)
	{
		editor.doc.setValue("Disconnected");
	}

	editor.on("blur", () =>
	{
		ws.send(editor.doc.getValue());
	});

}
