#= require jquery
#= require backbone

root = window || @

class SideBar extends Backbone.View

	scrollSideBar: (e) ->
		console.log e
		false

root.SideBar = SideBar
