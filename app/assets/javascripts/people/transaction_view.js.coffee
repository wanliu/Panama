root = window || @


class TransactionsView extends Backbone.View

	LEFT = 37
	RIGHT = 39

	initialize: (@options) ->

		$(window).keydown($.proxy(@keyDown, @))

	currentTarget: () ->
		$trans = $("#transactions .transaction")
		$(_($trans).find (elem) ->
			$(elem).position().top - $(window).scrollTop() - 80 >= 0)

	keyDown: (e) ->
		target = if e.which == LEFT
					@currentTarget().prev()
				else if e.which == RIGHT
					@currentTarget().next()

		@scrollTo(target) if target? && target.length > 0

	scrollTo: (target) ->
		$("html, body").animate({ scrollTop: target.position().top - 80 });


root.TransactionsView = TransactionsView