root  = window || @

class root.ApplyJoinCircle extends Backbone.View

	events:
		"click " : "apply_join_circle"

	apply_join_circle: () ->
		$.ajax({
			dataType: "json",
			type: "post",
			data:{ id: @model.id},
			url: "/people/#{@options.current_user_login}/circles/apply_join",
			success: (notice) =>
				pnotify({text: notice.message })
				if notice.type == "waiting"
					$(@el).replaceWith("<span class='label-warning waiting'>等待确认</span>")
				else
					$(@el).replaceWith("<span class='label label-warning be_in'>已加入</span>")
			error: (notice)=>
				message = JSON.parse(notice.responseText).message
				pnotify({text: message })
		})


class ApplyJoinCircleList extends Backbone.View
	initialize: () ->
		_.extend(@, @options)
		els = $(".add_circle")
		_.each els, (el) =>
			new ApplyJoinCircle({
				el: el,
				model: {id: $(el).attr("data-value-id")},
				current_user_login: @current_user_login,
			})

root.ApplyJoinCircleList = ApplyJoinCircleList