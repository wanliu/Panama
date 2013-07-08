root = (window || @)

class TopBar extends Backbone.View

	events: 
		"click .link.friends": "toggleFriends"

	toggleFriends: () ->
		$("body").toggleClass("open_right_side")
		$(window).trigger('resize')
		false



root.TopBar = TopBar
