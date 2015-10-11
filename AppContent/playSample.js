// Given a track URL in params.url, play the preview for that track.
var pageHandler = function(params)
{
	"use strict";
	
	var contentTask = resourceLoader.load(params.url, function(status, result) {
		if (status == 200) {
			load(result);
		} else {
			failLoading();
		}
	});
	
	function load(content) {
		var trackJSON = JSON.parse(content);
		
		var track = new MediaItem("audio", trackJSON.preview_url);
		track.artworkImageURL = trackJSON.album.images[0].url;
		track.title = trackJSON.name;
		track.isExplicit = trackJSON.explicit;
		
		var player = new Player();
		player.playlist = new Playlist();
		player.playlist.push(track);
		player.play();
	}
}
