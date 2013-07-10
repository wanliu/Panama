#= require jquery
#= require backbone
exports = window || @
class exports.SpinnerView extends Backbone.View
	events: {
		'click .spinner-up' : 'spinnerUp',
		'click .spinner-down': 'spinnerDown'
	},
	spinnerUp: () ->
		$input = @getInput()
		$input.val(parseInt($input.val())+1)

	spinnerDown: () ->
		$input = @getInput()
		if (parseInt($input.val())) > 2
			$input.val(parseInt($input.val())-1)
		else
			$input.val(1)

	getInput: () ->
		@$el.find("input[type='text']")