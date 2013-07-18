root = window || @

class edit extends Backbone.View

	initialize : (options) ->
   	 	_.extend(@, options)

	events:
		"click table td" : "edit"
		"blur table td" : "blur"
		"hover table td" : "hover"

	edit: (event)->
		if $(event.currentTarget) isnt 'input'
			$(event.currentTarget).addClass('input')
				.html('<input type="text" value="'+ $(event.currentTarget).text() +'" />')
				.find('input')
				.focus()
			blur()
			hover()

	blur: ()->
		$(event.currentTarget).parent().removeClass('input').html($(event.currentTarget).val() || 0)

	hover: ()->
		$(this).addClass('hover')