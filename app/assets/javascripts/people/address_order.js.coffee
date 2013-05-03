define ['jquery', 'backbone', 'exports'], 
($, Backbone, exports) ->

	class AddressOrderView extends Backbone.View
		initialize: (options) ->
			_.extend(@, options)
			@$el = $(@el)
			@option_el = $(".address_input")
			@custom_el = $(".address-panel")
			optionView = new AddressOptionView({
				el: @option_el
			})
			customView = new AddressCustomView({
				el: @custom_el
			})


	class AddressOptionView extends Backbone.View
		initialize: (options) ->
			_.extend(@, options)
			@$el = $(@el)

		events:
			"click div.address-add" : "add_address"

		add_address: () ->
			debugger


	class AddressCustomView extends Backbone.View
		initialize: (options) ->
			_.extend(@, options)
			@$el = $(@el)
			@$el.hide()


	exports.AddressOrderView = AddressOrderView
	exports