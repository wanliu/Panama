root = window || @

class CircleCreate extends Backbone.View

	initialize: () ->
		_.extend(@ ,@options)
		@$el = $(@el)

	events:
		"click .submit_cirlce" : "submit_data"
			
	submit_data: () -> 
		name = @$(".circle_name").val()
		introduce = @$(".introduce").val()
		attachment_id = @$(".attachable > input").val()
		city_id = @$(".address_area_id").val()
		limit_city = true if @$(".limit_area").attr("checked") == "checked"
		limit_join = true if @$(".apply_join").attr("checked") == "checked"

		$.ajax({
			type: "post",
			dataType: "json",
			data: { circle: { 
						name: name, 
						description: introduce, 
						attachment_id: attachment_id,
						city_id: city_id 
					},
					setting:{
					    limit_city: limit_city, 
					    limit_join: limit_join
					}
				},
			url:"/people/#{@current_user}/communities",
			success: () =>
				window.location.href = "/people/#{ @current_user }/communities"
		})

root.CircleCreate = CircleCreate