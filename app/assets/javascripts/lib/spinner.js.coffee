
define ['jquery','backbone','exports'], ($,Backbone,exports) ->
	class SpinnerView extends Backbone.View 
		events: {
			'click .spinner-up' : 'spinner_up',
			'click .spinner-down': 'spinner_down'
		},
		spinner_up: ()-> 
			$input = @.$el.find("input[type='text']")
			$input.val(parseInt($input.val())+1)
			false

		spinner_down: ()-> 
			$input = @.$el.find("input[type='text']")
			$input.val(parseInt($input.val())-1) 
			false

	exports.SpinnerView = SpinnerView
	exports