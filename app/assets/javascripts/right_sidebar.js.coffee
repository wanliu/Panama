
root = (window || @)


class RightSideBar extends Backbone.View
	events: 
		"click #sidebar-settings>[data-value=icons]": "toggleIcons"
		"click #sidebar-settings>[data-value=auto]": "toggleAuto"		


	toggleIcons: (e) ->
		$("body").addClass('right-mini');
		$(window).trigger('resize')

	toggleAuto: (e) ->
		$("body").removeClass('right-mini');
		$(window).trigger('resize')

root.RightSideBar = RightSideBar