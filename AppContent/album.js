var pageHandler = function(params)
{
	"use strict";
	
	var resources = {
		content: "https://api.spotify.com/v1/albums/" + params.album,
		template: "vnd.myapp.local:albumTemplate.tvml",
		strings: "vnd.myapp.local:albumStrings.json",
	};
	resourceLoader.loadMultiple(resources, function(status, result) {
		if (status == 200) {
			load(result);
		} else {
			failLoading();
		}
	});
	
	var strings = null;
	function load(resources) {
		var parser = new DOMParser;
		var document = parser.parseFromString(resources.template, "application/xml");
		var albumJSON = JSON.parse(resources.content);
		strings = resources.strings;
		
		if (document && albumJSON) {
			constructAlbumPage(document, albumJSON);
			pushDoc(document);
		} else {
			failLoading();
		}
	}
	
	function failLoading() {
		logger.log("Failed to load album " + params.url);
	}
	
	function constructAlbumPage(document, albumJSON) {
		replacePlaceholders(document, {
			"$ALBUM_TITLE": albumJSON.name,
			"$ALBUM_SUBTITLE": buildAlbumSubtitle(albumJSON),
		});
		
		var albumArt = albumJSON.images[0].url;
		document.getElementById("album_cover").setAttribute("src", albumArt);
		
		var trackTemplate = document.getElementById("track_template");
		var trackListContainer = trackTemplate.parentNode;
		trackListContainer.removeChild(trackTemplate);
		trackTemplate.removeAttribute("id");
		
		albumJSON.tracks.items.forEach(function(track, index) {
			var trackNode = trackTemplate.cloneNode(true);
			
			replacePlaceholders(trackNode, {
				"$TRACK_INDEX": index + 1,
				"$TRACK_TITLE": track.name,
				"$TRACK_SUBTITLE": buildTrackSubtitle(track),
			});
			
			trackNode.setAttribute("url", "vnd.myapp.local:playSample.js?url=" + encodeURIComponent(track.href));
			trackNode.setAttribute("play_url", "vnd.myapp.local:playSample.js?url=" + encodeURIComponent(track.href));
			
			trackListContainer.appendChild(trackNode);
		});
	}
	
	function buildAlbumSubtitle(albumJSON) {
		var artists = albumJSON.artists.map(function(artist) {
			return artist.name;
		});
		var result = artists.join(", ");
		var type = strings["albumType_" + albumJSON.album_type];
		if (type) {
			result = type + " • " + result;
		}
		return result;
	}
	
	function buildTrackSubtitle(trackJSON) {
		var seconds = Math.round(trackJSON.duration_ms / 1000);
		var minutes = Math.trunc(seconds / 60);
		seconds %= 60;
		var result = minutes + ":";
		if (seconds < 10) {
			result += "0";
		}
		result += seconds;
		if (trackJSON.explicit) {
			result += " • Explicit";
		}
		return result;
	}
	
	// Replace each key in replacements with the corresponding value in every text node in a subtree.
	function replacePlaceholders(node, replacements) {
		if (node.nodeType == 3) {
			var data = node.data;
			Object.keys(replacements).forEach(function(key) {
				data = data.replace(key, replacements[key]);
			});
			node.data = data;
		} else {
			var children = node.childNodes;
			for (var i = 0; i < children.length; i++) {
				replacePlaceholders(children.item(i), replacements);
			}
		}
	}
}
