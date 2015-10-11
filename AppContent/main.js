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
		var targetID = event.target.getAttribute("id");
		if (targetID) {
			logger.log("User selected " + targetID);
		}
	});
	navigationDocument.pushDocument(document);
}

App.onLaunch = function(options) {
	var templateURL = "vnd.myapp.local:alertTemplate.tvml";
	getDocument(templateURL);
}

App.onExit = function() {
	console.log("App finished");
}
