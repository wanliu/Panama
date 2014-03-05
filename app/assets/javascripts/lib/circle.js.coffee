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
				try
					pnotify(text: JSON.parse(ms.responseText), type: "error")
				catch err
					pnotify(text: ms.responseText, type: "error")
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
				window.location.reload()
		})

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
root.CircleAddressView = CircleAddressView
