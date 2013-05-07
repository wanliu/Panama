define ['jquery', 'backbone', 'exports'], 
($, Backbone, exports) ->

	class AddressOrderView extends Backbone.View
		initialize: (options) ->
			_.extend(@, options)
			@$el = $(@el)
			@option_el = @$(".address_input")
			@custom_el = @$(".address-panel")
			optionView = new AddressOptionView({
				parentView: @,
				el: @option_el
			})
			customView = new AddressCustomView({
				parentView: @,
				el: @custom_el
			})


	class AddressOptionView extends Backbone.View
		initialize: (options) ->
			_.extend(@, options)
			@$el = $(@el)

		events:
			"mouseup abbr:first"	     :  "option_reset"
			"click .address-add>button"  :  "add_address"
			"click .chzn-results>li"     :  "option_select"

		option_reset: () ->
			@$el.find("abbr:first").trigger("mouseup")
			@parentView.custom_el.slideDown()

		add_address: () ->
			@$el.find("abbr:first").trigger("mouseup")
			@parentView.custom_el.slideToggle()
			false

		option_select: () ->
			@parentView.custom_el.slideUp()


	class AddressCustomView extends Backbone.View
		initialize: (options) ->
			_.extend(@, options)
			@$el = $(@el)
			@render()

		render: () ->
			if @parentView.option_el.find("abbr").length
				@$el.slideDown()


	exports.AddressOrderView = AddressOrderView
	exports