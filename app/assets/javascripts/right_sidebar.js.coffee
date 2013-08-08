
root = (window || @)


class RightSideBar extends Backbone.View
	events: 
		"click #sidebar-settings>[data-value=icons]": "toggleIcons"
		"click #sidebar-settings>[data-value=auto]": "toggleAuto"		

	initialize: (options) ->
		_.extend(options, @)
		@$el = $(@el)
		@activities_notice = new ActivitiesNotice({ 
			el: @$el.find("#activities-notice") 
		})

	toggleIcons: (e) ->
		$("body").addClass('right-mini');
		$(window).trigger('resize')

	toggleAuto: (e) ->
		$("body").removeClass('right-mini');
		$(window).trigger('resize')


class ActivitiesNotice extends Backbone.View

	initialize: (options) ->
		_.extend(options, @)
		@$el = $(@el)

root.RightSideBar = RightSideBar