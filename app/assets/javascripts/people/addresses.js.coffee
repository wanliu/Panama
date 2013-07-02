# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
exports = window || @

class exports.Address extends Backbone.View
	initialize: (options) ->
    _.extend(@, options)
