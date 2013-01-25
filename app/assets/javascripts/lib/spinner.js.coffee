
define ['jquery','backbone','exports'], ($,Backbone,exports) ->
	class SpinnerView extends Backbone.View
		initialize: (options) ->
			_.extend(@,options)
			@el = $(".#{@discern_class}")
			@.$input = @el.find("input[type='text']")
			$(".spinner-up",@el).bind("click",$.proxy(@spinner_up,@))
			$(".spinner-down",@el).bind("click",$.proxy(@spinner_down,@))

		spinner_up: ()-> 
			@.$input.val(parseInt(@.$input.val())+1)
			false

		spinner_down: ()-> 
			@.$input.val(parseInt(@.$input.val())-1)
			false

	exports.SpinnerView = SpinnerView
	exports