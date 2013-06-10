define ['jquery', 'backbone', 'exports'], ($, Backbone, exports) ->

	class SideBar extends Backbone.View

		scrollSideBar: (e) ->
			console.log e
			false

	exports.SideBar = SideBar
	exports