# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
root = window || @

class YellowInfoPreview extends Backbone.View
	
	events: 
		"mouseover .user_icon" : "delay_get"
		"mouseout  .user_icon" :  "delay_dispear"

		"mouseenter .yellow_base_info"  : "change_status"
		"mouseleave .yellow_base_info" : "dispear"
	
	initialize: () ->
		@template1 = Hogan.compile($("#yellow_page_hover_buyer_template").html())
		@template2 = Hogan.compile($("#yellow_page_hover_seller_template").html())
		@flag = ""

	delay_get: () ->
		@flag = "in"
		setTimeout () =>
			@load_user_info()
		, 2000

	delay_dispear: () ->
		@flag = "out"
		setTimeout () =>
			@dispear()
		, 3000

	change_status: () ->
		@flag = "in"

	load_user_info: () ->
		id = @el.id
		if $(@el).find(".yellow_base_info").length > 0
			if @flag == "in"
				$(@el).find(".yellow_base_info").fadeIn("slow")
			else
				$(@el).find(".yellow_base_info").fadeOut("slow")
		else
			$.ajax({
				dataType: "json",
				type: "get",
				url: "/yellow_page/"+id,
				success: (user) =>
					modal = @render(user)
					if @flag = "in"
						$(@el).append(modal)
					else
						$(@el).append(modal).css("display","none")
			})

	render: (user) =>
		if user.service_id == 1 
			tpl = @template1
		else
			tpl = @template2
		tpl.render(user)

	dispear: () ->
		if @flag = "out"
			$(@el).find(".yellow_base_info").fadeOut("slow")

	show: () ->
		$(@el).show()


class YellowInfoPreviewList extends Backbone.View

	initialize: () ->
		_.each $(".user_info"), (el) ->
			new YellowInfoPreview({el: el})

root.YellowInfoPreviewList = YellowInfoPreviewList