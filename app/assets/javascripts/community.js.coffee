#= require panama
#= require ajaxify
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require backbone
#= require following
#= require topic

root = window || @

class CircleCategory extends Backbone.View

	initialize: () ->
		_.extend(@, @options)

	events:
		"click .add_category" : "edit"
		"blur .new_category" : "submit"

	edit: () ->
		@$(".add_category").hide()
		input = $("<input type='text' placeholder='新类别' class='new_category span11'/>").insertBefore(".add_category")
		input.focus()

	submit: () ->
		$category_name = $(".new_category").val()
		@$(".new_category").remove()
		@$(".add_category").show()
		if $category_name != ""
			$.ajax({
				type: "post",
				dataType: "json",
				data: { name: $category_name },
				url: "/communities/#{ @circle_id }/circles/add_category",
				success: (data) =>
					$("<li><a data-value-id='#{ data.id}' href='#' class='circle-category-#{data.id}'>#{ data.name} </a></li>").insertBefore(".add_category")	
			})


class CircleListView extends Backbone.View
  events:
    "click .following .join" : "join_circle"
  initialize: (option) ->
    _.extend(@, option)

    @$left = @$(".left")
    @$right = @$(".right")

    @topics = new TopicViewList(
      sp_el: @el,
      add_topic: _.bind(@add_topic, @),
      fetch_url: "/communities/#{@circle_id}/topics")

    @view = new CreateTopicView(
      circle_id: @circle_id,
      create_topic: _.bind(@create_topic, @),
      el: @$(".left>.toolbar"))

  add_topic: (template) ->
    @short_elem().append(template)

  create_topic: (template) ->
    @short_elem().prepend(template)

  short_elem: () ->
    ltopic = $(".topics", @$left)
    rtopic = $(".topics", @$right)
    if @$left.height() > @$right.height() then rtopic else ltopic

  join_circle: () ->
    $.ajax(
      url: "/communities/#{@circle_id}/circles/join"
      type: "POST",
      success: () =>
        window.location.href = "/communities/#{@circle_id}/circles"
    )


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


root.CircleCategory = CircleCategory
root.CircleListView = CircleListView
root.CircleAddressView = CircleAddressView
root.CircleCreate = CircleCreate
root.CircleUpdate = CircleUpdate
root.CircleCategoryList = CircleCategoryList
