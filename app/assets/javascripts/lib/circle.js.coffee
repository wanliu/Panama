root = window || @

class CircleCreate extends Backbone.View

	initialize: () ->
		_.extend(@ ,@options)
		@$el = $(@el)

	events:
		"click .submit_cirlce" : "submit_data"	

	check_data: () ->
		unless @$(".circle_name").val()
			@$(".circle_name").addClass('error')
			return false
		if  isNaN($(".address_area_id").val())
			@$(".address_province_id").addClass('error')
			@$(".address_city_id").addClass('error')
			@$(".address_area_id").addClass('error')
			return false
		true
			
	submit_data: () -> 
		return false unless @check_data()
		$.ajax({
			type: "post",
			dataType: "json",
			data: { circle: { 
					name: @$(".circle_name").val(), 
					description: @$(".introduce").val(), 
					attachment_id: @$(".attachable > input").val(),
					city_id: @$(".address_area_id").val()
				},
				setting:{
			    limit_city: @$(".limit_area").is(':checked'), 
			    limit_join: @$(".limit_join").is(':checked')
				}
			},
			url: @remote_url,
			success: () =>
				if @current_user
					window.location.href = @remote_url
				else
					window.location.href = "/shops/#{ @current_shop }/admins/communities"
			error: (ms) ->
				pnotify(text: JSON.parse(ms.responseText), type: "error")
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
			type: "put",
			data: data,
			url: "/communities/#{ @circle_id }/circles/update_circle",
			type: "put",
			success: () =>
				window.location.href = "/communities/#{ @circle_id }/circles"
		})


class CircleCategoryView extends Backbone.View
	events: 
		"click .icon-remove": "remove"
		"blur .circle_category_input": "update_category"
		"click .icon-edit": "edit_view"	
		"keyup .circle_category_input" : "enter"

	initialize: () ->		
		@circle_id = @options.circle_id

	remove: (e) ->
		id = @$el.attr("data-value-id")
		$.ajax({
			type: "delete",
			dataType: "json",
			url: "/communities/#{ @circle_id }/categories/"+id,
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
			data: { name: name },
			url: "/communities/#{ @circle_id }/categories/"+category_id,
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
		"click .new_input"          : "new_input"
		"blur .new_circle_category" : "add_category"
		"keyup .new_circle_category": "enter"

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
		if @$(".new_input").hasClass("disabled")
			return
		else
			@$(".categories").append("<input type='text' class='new_circle_category'>")
			@$(".new_circle_category").focus()
			@$(".new_input").addClass("disabled")
	
	add_category: ()->
		$category_name = $(".new_circle_category").val()
		@$(".new_circle_category").remove()
		if $category_name != ""
			$.ajax({
				type: "post",
				dataType: "json",
				data: { name: $category_name },
				url: "/communities/#{ @circle_id }/categories",
				success: (data) =>
					el = $(@template.render(data))
					view = new CircleCategoryView({
						el: el,
						circle_id: @circle_id
					})
					@$(".categories").append(view.el)
			})
		@$(".new_input").removeClass("disabled")
			

class CircleAddressView extends Backbone.View

	province_call: () ->

	city_call: () ->

	area_call: () ->

	initialize: () ->
		_.extend(@, @options)
		@$el = $(@el)
		@load_province()
		@load_depend_chose()

	load_province: () ->
		$.ajax({
			type: "get"
			url: "/city/province",
			dataType: 'json',
			data: {},
			success: (data) =>
				strHtml = "<option value=''>--请选择--</option>"
				_.each data, (num) =>
					strHtml += "<option value='#{num["id"]}'>#{num["name"]}</option>"
				@$el.find(".address_province_id").html(strHtml)
				@province_call() 
		})

	load_depend_chose: () ->    
		@depend_select(
			@$(".address_province_id"), 
			@$(".address_city_id"), 
			""
		)     
		@depend_select(
			@$(".address_city_id"),
			@$(".address_area_id"), 
			"/city/",
			@city_call
		)      
		@depend_select(
			@$(".address_area_id"), 
			"", 
			"/city/",
			@area_call	
		)    

	depend_select: (el, children, url, call_back = () ->) ->     		
		new DependSelectView({
			el: el,
			children: children,
			url: url,
			call_back: _.bind(call_back, @)
		})


root.CircleCreate = CircleCreate
root.CircleUpdate = CircleUpdate
root.CircleCategoryList = CircleCategoryList
root.CircleAddressView = CircleAddressView
