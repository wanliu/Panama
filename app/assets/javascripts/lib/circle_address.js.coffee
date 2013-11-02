root = window || @

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
		
root.CircleAddressView = CircleAddressView
