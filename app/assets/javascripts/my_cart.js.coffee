define ['jquery', 'backbone', 'exports'] , ($, Backbone, exports) ->

	class HoverManager

		default_options = {
			timeOut: 1500
		}

		constructor: (@over_elements, @options) ->
			@hover = false

		signalProcess: (event) ->
			_(@over_elements).include(event.currentTarget)


		checkStatus: (event) ->



	class MyCart extends Backbone.View
		el: "#my_cart"

		events: 
			"click .handle": "toggleCartBox"

		initialize: (@options) ->
			@hm = new HoverManager(@$("a.handle, #cart_box"))

		toggleCartBox: (event) ->
			$("#cart_box")
				.toggle () ->
					if $(@).hasClass "fadeInUpBig" 
						'animate fadeInDownBig show'
					else 
						'animate fadeInUpBig'

		hoverProcess: (event) ->
			@$("#cart_box")
				.show()
				.addClass("animated fadeInUpBig")
			# @hm.signalProcess(event)

		blurProcess: (event)->
			$(@el)
				.addClass("animated fadeInDownBig")



