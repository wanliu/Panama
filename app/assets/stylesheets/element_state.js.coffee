root = window || @

class ElementState extends BackBone.View
	initialize: () ->
		_.extend(@, @options)
		@connect()
	
	disconnect_state: () ->
		$("[data-realtime-state]").each () ->
			$(@).attr("data-realtime-state"，"disconnect")

	connect: () ->
		$("[data-realtime-state]").each () ->
			$(@).attr("data-realtime-state"，"connect")

root.ElementState = ElementState
