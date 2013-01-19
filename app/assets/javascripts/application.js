// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//


define('Panama', function(require, exports, modules){	
	var $ = require('jquery');
	var $ = require('jquery_ui');
	var h5bp = require('h5bp');
	var chosen = require('lib/chosen.ex');
	var ajax_auth = require('wanliu/ajax_auth_client')

	AjaxAuthClient.setupRetrieveLoginUrlCallback(function(url){                
	})

	AjaxAuthClient.registreLoginSuccess(function(user){        
	})
});

 