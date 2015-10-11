function getDocument(url) {
	return resourceLoader.load(url, function(status, result) {
		if (status == 200) {
			var parser = new DOMParser;
			document = parser.parseFromString(result, "application/xml");
			pushDoc(document);
		} else {
			// This error handling could be better.
			logger.log("Loading error: " + status + ", " + result);
		}
	});
}

function pushDoc(document) {
	document.addEventListener("select", function(event) {
		var action = event.target.getAttribute("action");
		if (action) {
			eval(action);
		} else {
			var url = event.target.getAttribute("url");
			if (url) {
				openInternalURL(url);
			}
		}
	});
	document.addEventListener("play", function(event) {
		var action = event.target.getAttribute("play_action");
		if (action) {
			eval(action);
		} else {
			var url = event.target.getAttribute("play_url");
			if (url) {
				openInternalURL(url);
			}
		}
	});
	navigationDocument.pushDocument(document);
}

function openInternalURL(url) {
	// Pages within the app are represented by URLs which represent JavaScript source files. Query parameters are passed
	// to the JavaScript rather than the server.
	var paramIndex = url.indexOf("?");
	var params = {}
	if (paramIndex != -1) {
		var paramString = url.substring(paramIndex + 1, url.count);
		url = url.substring(0, paramIndex);
		paramString.split("&").forEach(function(part) {
			var item = part.split("=");
			params[item[0]] = decodeURIComponent(item[1]);
		});
	}
	
	// Convert vnd.myapp URLs to https: or file: as appropriate.
	url = resourceLoader.resolveURL(url);
	
	evaluateScripts([url], function(success) {
		if (success && pageHandler) {
			pageHandler(params);
			delete pageHandler;
		}
		else
		{
			logger.log("Failed to load " + url + ". TVMLKit doesn't want to tell us why.");
		}
	});
}

App.onLaunch = function(options) {
	evaluateScripts([resourceLoader.resolveURL("vnd.myapp.local:ResourceLoader.js")], function(success) {
		if (success) {
			openInternalURL("vnd.myapp.local:introAlert.js");
		} else {
			logger.log("uh-oh")
		}
	});
}

App.onExit = function() {
	console.log("App finished");
}
