define ['jquery','backbone'], ($,Backbone) ->
	
	class SpinnerView extends Backbone.View 
		events: {
			'click .spinner-up' : 'spinnerUp',
			'click .spinner-down': 'spinnerDown'
		},
		spinnerUp: () -> 
			$input = @getInput()
			$input.val(parseInt($input.val())+1)
			false

		spinnerDown: () -> 
			$input = @getInput()
			$input.val(parseInt($input.val())-1) 
			false

		getInput: () ->
			@$el.find("input[type='text']") 