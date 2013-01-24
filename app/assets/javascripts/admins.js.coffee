require(['panama', 'ajaxify', 'jquery', 'jquery_ujs', "backbone"], (panama, ajaxify, $, jquery_ujs, Backbone) ->
	Backbone.Model.extend({idAttribute : "_id"})
)