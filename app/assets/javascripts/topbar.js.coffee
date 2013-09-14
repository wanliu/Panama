root = (window || @)

class TopBar extends Backbone.View

	events:
		"click .link.friends": "toggleFriends"
		"submit form"        : "enterSearch"

	initialize: (@options) ->
		@resultTarget = $(@options['results'] || '#activities')
		$('.link.friends').bind('click', $.proxy(@toggleFriends, @))
		@toggleFriends()

	toggleFriends: () ->
		$("body").toggleClass("open_right_side")
		# $('.right-sidebar').animate({ width: 'toggle'},callback)
		$(window).trigger('resize')
		false

	enterSearch: (e) ->
		@$("[type=search]")
		query = @$("[type=search]").val()
		if query > ""
			$.get("/search/products",
				{ q: query },
				$.proxy(@successSearch, @)
			)
		false

	successSearch: (data) ->
		#@$("[type=search]").val("")
		$(window).trigger('search_result:reset', data: data)


root.TopBar = TopBar