define(function(require, exports, module){
	$ = require('jquery');
	
	exports.loadPage = function(query, url){
		$.get(url, {ajaxify: true}, function(data){
			$(query).replaceWith(data);
		});
	}	
});