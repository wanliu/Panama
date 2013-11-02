root = (window || @)

class TopBar extends Backbone.View

	events:
		"click .link.friends": "toggleFriends"
		"click .search-btn"  : "enterSearch"
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
		query = @$("[type=search]").val().trim()
		$(window).trigger('reset_search', {title: query}) if query
		false


root.TopBar = TopBar