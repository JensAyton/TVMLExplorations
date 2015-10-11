// Given a map of keys to URLs, loads all of the URLs and calls resultHandler(status, result) with status = 200 and
// result = a map of the same keys to loaded data. If an error occurs, resultHandler is called with a different status
// code and result = an error string, as for load().
// Returns an object with one method, cancel().
resourceLoader.loadMultiple = function(targets, resultHandler) {
	"use strict";
	
	var tasks = [];
	var results = {};
	
	var metaTask = {
		cancel: function() {
			tasks.forEach(task, function() {
				task.cancel();
			});
			tasks = [];
		}
	};
	
	var remaining = Object.keys(targets).length;
	
	Object.keys(targets).forEach(function(key) {
		resourceLoader.load(targets[key], function(status, result) {
			if (status == 200) {
				results[key] = result;
				remaining--;
				if (remaining == 0) {
					resultHandler(200, results);
					tasks = [];
				}
			} else {
				metaTask.cancel();
				resultHandler(status, result);
			}
		});
	});
	
	return metaTask;
}
