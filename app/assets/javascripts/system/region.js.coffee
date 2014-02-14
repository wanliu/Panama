root = window || @

class RegionView extends Backbone.View

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)

	events:
		"click .region_create" : "submit_region"
		"click .confirm_choice" : "confirm_city"
		"click .icon-remove" : "remove"

	remove: (event) ->
		event.currentTarget.parentElement.remove()

	confirm_city: () ->
		$part_ids = []
		_.each @$(".city_list > li > input"), (item) ->
			if $(item).attr("checked") == "checked"
				$part_ids.push($(item).attr("id"))
		$.ajax({
			dataType: "json",
			type: "get",
			data: {part_ids: $part_ids},
			url: "/system/regions/get_city",
			success: (datas) =>
				@render(datas)
		})	

	render: (datas) ->
		strHtml = ""
		_.each datas, (part) =>
			strHtml += "<li  id='#{part["id"]}'>#{part["name"]}<i class ='icon-remove'></i></li>" 
		@$(".address_part_list").append(strHtml)	

	submit_region: () ->
		$part_ids = []
		$attachment_ids = []
		$region_id = @$(".region_id").attr("value")
		$region_name = @$(".region_name_input").val()
		$ad = @$(".ad").val()
		_.each @$(".address_part_list > li"), (item) ->
			$part_ids.push($(item).attr("id"))

		_.each @$(".attachment-list .attachable > input:hidden"), (item) ->
			if $(item).attr("value") != ""
				$attachment_ids.push($(item).attr("value"))

		$.ajax({
			type : "post",
			dataType: "json",
			url: "/system/regions/create_region",
			data: {region_name: $region_name, part_ids: $part_ids, attachment_ids: $attachment_ids, region_id :$region_id, ad: $ad }
			success: () ->
				window.location.href = "/system/regions"
			error: (rep) ->
				m = JSON.parse(rep.responseText)
				pnotify({text: m })
		})

root.RegionView = RegionView

