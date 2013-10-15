root  = window || @

class ApplyJoinCircle extends Backbone.View

	events: 
		"click " : "apply_join_circle"

	apply_join_circle: () ->
		$.ajax({
			dataType: "json",
			type: "post",
			data:{ id: $(@el).attr("data-value-id")},
			url: "/people/#{@options.current_user_login}/circles/apply_join",
			success: (notice) =>
				message = JSON.parse(notice.responseText).message
				pnotify({text: message })
				type = JSON.parse(notice.responseText).type
				if type == "waiting"
					$(@el).html("<a href='#' class='label label-warning waiting'>等待确认</a>")
				else
					$(@el).html("<a href='#' class='label label-warning be'>已加入</a>")
			error: (notice)=>
				message = JSON.parse(notice.responseText).message
				pnotify({text: message })

		})
		false


class ApplyJoinCircleList extends Backbone.View
	initialize: () ->
		_.extend(@, @options)
		_.each $(".add_circle"), (el) =>
			new ApplyJoinCircle({ 
				el: el,
				current_user_login: @current_user_login,
			})

root.ApplyJoinCircleList = ApplyJoinCircleList