#= require jquery
#= require backbone

root = window || @

class SocialSideBar extends Backbone.View

	scrollSideBar: (e) ->
		console.log e
		false

root.SocialSideBar = SocialSideBar
