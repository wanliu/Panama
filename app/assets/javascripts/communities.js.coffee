# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
root = window || @

class YellowInfoPreview extends Backbone.View

	events:
		"mouseenter ": "load_user_info"
		"mouseleave ": "hide_user_info"

	initialize: () ->
		_.extend(@, @options)
		@template1 = Hogan.compile($("#yellow_page_hover_buyer_template").html())
		@template2 = Hogan.compile($("#yellow_page_hover_seller_template").html())

	load_user_info: (event) ->
		if @$(".yellow_base_info").length > 0
			@show_user_info()
		else
			$.ajax({
				dataType: "json",
				type: "get",
				url: "/communities/" + @el.id,
				success: (user) =>
					modal = @render(user)
					$(@el).append(modal)
					@show_user_info()
			})

	render: (user) =>
		if user.service_id == 1
			tpl = @template1
		else
			tpl = @template2
		tpl.render(user)

	show_user_info: () =>
		$(".yellow_base_info").stop()
		@$(".yellow_base_info").slideUp()
		@$(".yellow_base_info").slideDown({
			speed: "slow",
			start: () =>
				_.each $(".yellow_base_info"), (el) =>
					$(el).hide() unless el == @$(".yellow_base_info")[0]
		})

	hide_user_info: () ->
		@$(".yellow_base_info").hide()

class YellowInfoPreviewList extends Backbone.View

	initialize: () ->
		_.each $(".user_info"), (el) =>
			new YellowInfoPreview({el: el})


root.YellowInfoPreviewList = YellowInfoPreviewList