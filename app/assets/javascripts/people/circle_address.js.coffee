root = window || @

class CircleAddressView extends Backbone.View

	initialize: () ->
		_.extend(@, @option)
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
			"/city/"
		)      
		@depend_select(
			@$(".address_area_id"), 
			"", 
			"/city/"
		)    

	depend_select: (el, children, url) ->     
		new DependSelectView({
			el: el,
			children: children,
			url: url,
		})
		
root.CircleAddressView = CircleAddressView
