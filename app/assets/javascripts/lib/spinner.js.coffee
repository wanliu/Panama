define ['jquery','backbone'], ($,Backbone) ->
	
	class SpinnerView extends Backbone.View 
		events: {
			'click .spinner-up' : 'spinnerUp',
			'click .spinner-down': 'spinnerDown'
		},
		spinnerUp: () -> 
			$input = @getInput()
			$input.val(parseInt($input.val())+1)

		spinnerDown: () -> 
			$input = @getInput()
			if (parseInt($input.val())) > 0
				$input.val(parseInt($input.val())-1) 
			else
				$input.val(0)

		getInput: () ->
			@$el.find("input[type='text']") 