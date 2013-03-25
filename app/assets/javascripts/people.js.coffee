define ["jquery", "backbone"], ($, Backbone) ->

	class Following extends Backbone.View

		events: {
			"click .following"   : "following"
			"click .unfollowing" : "unfollowing"
		}

		initialize: (@options) ->
			_.extend(@, options)

		url: () ->
			if @following_type == "User"
				"/people/#{@login}/followings/user/"

			if @following_type == "Shop"
				"/people/#{@login}/followings/shop/"

		send_following: (following_id) ->
			$.post(@url(), {}following_id, "json")

		following: () ->
			following_id = $(".following").attr("data-value")
			@url(following_id)

		unfollowing: () ->
			following_id = $(".unfollowing").attr("data-value")
			@url(following_id)


	Following