define ['jquery', 'backbone', 'exports'] , ($, Backbone, exports) ->

	class HoverManager

		default_options = {
			timeOut: 1500
		}

		constructor: (@over_elements, @options) ->
			@hover = false

		signalProcess: (event) ->
			debugger
			_(@over_elements).include(event.currentTarget)


		checkStatus: (event) ->



	class MyCart extends Backbone.View
		el: "#my_cart"

		events: 
			"hover .handle": "signalProcess"
			"blur .handle": "signalProcess"

		initialize: (@options) ->
			@hm = new HoverManager(@$("a.handle, #cart_box"))

		signalProcess: (event) ->
			@hm.signalProcess(event)
