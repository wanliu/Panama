root = window || @

class TransactionsView extends Backbone.View

	initialize: (@options) ->

		$(window).keydown($.proxy(@keyDown, @))

	keyDown: (e) ->
		console.log e.which

root.TransactionsView = TransactionsView