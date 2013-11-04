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
			url: @remote_url,
			success: () =>
				if @current_user
					window.location.href = @remote_url
				else
					window.location.href = "/shops/#{ @current_shop }/admins/communities"
		})

class CircleCategoryView extends Backbone.View
	events: { 
		"click .icon-remove": "remove"
		"blur .circle_category_input": "update_category"
		"click .icon-edit": "edit_view"	
		"keyup .circle_category_input" : "enter"
	}

	initialize: () ->		
		@circle_id = @options.circle_id

	remove: (e) ->
		id = @$el.attr("data-value-id")
		$.ajax({
			type: "delete",
			dataType: "json",
			data: { category_id: id }
			url: "/communities/#{ @circle_id }/circles/del_category",
			success: () =>
				@$el.remove();
		})

	enter: (e) ->
		@$(".circle_category_input").blur() if e.keyCode == 13

	update_category: () ->
		category_id = @$el.attr("data-value-id")
		name = @$(".circle_category_input").val()
		$.ajax({
			type: "put",
			dataType: "json",
			data: {category_id: category_id,name: name },
			url: "/communities/#{ @circle_id }/circles/update_category",
			success: (data) =>
				@render(data)
		})

	render: (data) ->
		@$(".circle_category_input").val(data.name)
		@$(".category_name").text(data.name)
		@$(".circle_category_input").hide()
		@$(".category_name").show()

	edit_view: () ->
		@$(".circle_category_input").show()
		@$(".category_name").hide()

class CircleCategoryList extends Backbone.View

	events: 
		"click .new_input" : "new_input"
		"blur .new_circle_category" : "add_category"
		"keyup .new_circle_category" : "enter"

	initialize: () ->
		_.extend(@, @options)
		@template = Hogan.compile("<li data-value-id='{{ id }}' class='category span11'>
			<div class='replace span6'>
				<input type='text' class='circle_category_input' value= '{{ name }}'/>
				<span class='category_name'>{{ name }}</span>
			</div>
			<div class='operation span5'>
                <i class='icon-remove'></i><i class='icon-edit'></i>
            </div>
			</li>")

		els = $(".category")
		_.each els, (el) => 
			new CircleCategoryView({
				el: el,
				circle_id: @circle_id
			})
	enter: (e) ->
		@$(".new_circle_category").blur() if e.keyCode == 13
		
	new_input: () ->
		@$(".categories").append("<input type='text' class='new_circle_category'>")
	
	add_category: ()->
		$category_name = $(".new_circle_category").val()
		@$(".new_circle_category").remove()
		if $category_name != ""
			$.ajax({
				type: "post",
				dataType: "json",
				data: { name: $category_name },
				url: "/communities/#{ @circle_id }/circles/add_category",
				success: (data) =>
					el = $(@template.render(data))
					view = new CircleCategoryView({
						el: el,
						circle_id: @circle_id
					})
					@$(".categories").append(view.el)
			})

class CircleUpdate extends Backbone.View
	
	events: 
		"click .update_circle" : "update_circle"

	initialize: () ->
		_.extend(@, @options)

	data: () ->
		{
			setting:{
				limit_join: @$(".limit_join").is(':checked'),
				limit_city: @$(".limit_area").is(':checked')
			},
			circle:{
				name:  @$(".circle_name").val(),
				description: @$(".introduce").val(),
				city_id: @$(".address_area_id").val(),
				attachment_id: @$(".attachable > input:hidden").val()
			}
		}

	update_circle: () ->
		data = @data()
		$.ajax({
			data: data,
			url: "/communities/#{ @circle_id }/circles/update_circle",
			type: "put",
			success: () =>
				window.location.href = "/communities/#{ @circle_id }/circles"
		})

root.CircleUpdate = CircleUpdate
root.CircleCategoryList = CircleCategoryList
root.CircleCreate = CircleCreate