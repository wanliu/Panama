# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
root = window || @

class YellowInfoPreview extends Backbone.View
	
	events: 
		"mouseover .yellow_page .user_info .user_icon" : "delay_get"
		"mouseout  .yellow_page .user_info .user_icon" :  "delay_dispear"
		"mouseover .yellow_base_info"  : "show"
		"mouseout  .yellow_base_info" : "delay_dispear"
	
	initialize: () ->
		@template1 = Hogan.compile($("#yellow_page_hover_buyer_template").html())
		@template2 = Hogan.compile($("#yellow_page_hover_seller_template").html())

	delay_get: (event) ->
		setTimeout () =>
			@load_user_info(event)
		, 1000

	load_user_info: (event) ->
		id = event.currentTarget.parentElement.id
		if $(event.currentTarget.parentElement).find(".yellow_base_info").length > 0
			$(event.currentTarget.parentElement).find(".yellow_base_info").fadeIn("slow")
		else
			$.ajax({
				dataType: "json",
				type: "get",
				url: "/yellow_page/"+id,
				success: (user) =>
					modal = @render(user)
					$(event.currentTarget.parentElement).append(modal)
			})

	render: (user) =>
		if user.service_id == 1 
			tpl = @template1
		else
			tpl = @template2
		tpl.render(user)


	delay_dispear: (event) ->
		setTimeout () =>
			@dispear(event)
		, 1000

	dispear: (event) ->
		$(event.currentTarget.parentElement).find(".yellow_base_info").fadeOut("slow")

	show: (event) ->
		$(event.currentTarget).show()
		

root.YellowInfoPreview = YellowInfoPreview

