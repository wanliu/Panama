root = window || @

class RegionView extends Backbone.View

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)
	
	events:
		"click .region_create" : "submit_region"

	submit_region: () ->
		$part_ids = []
		$region_name = @$(".region_name_input").val()
		_.each @$("li > input"), (item) ->
			if $(item).attr("checked") == "checked"
				part_ids.push(item.id)

		$.ajax({
			type : "post",
			dataType: "json",
			url: "/system/regions",
			data: {region_name: $region_name, part_ids: $part_ids}
			success: () ->
				
		})

root.RegionView = RegionView

