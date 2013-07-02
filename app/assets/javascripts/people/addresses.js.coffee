# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
exports = window || @

class exports.Addresses extends Backbone.View
	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)

	events:
		"click #new_address .save-button" : "new_address"
		"click .address .delete-button"   : "delete_address"
		"click .address .edit-button"     : "update_address"

	new_address: (event) ->
		@$el.find("form#new_address_form").submit()

	delete_address: (event) ->
		if confirm("确定要删除该收货地址吗？")
			debugger
		

	update_address: (event) ->
		@$el.find("form#edit_address_form").submit()