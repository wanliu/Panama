root = (window || @)

class LeftSideBar extends Backbone.View
	ICON_CLASS = "sidebar-icons"

	events: 
		"click #sidebar-settings>[data-value=icons]": "toggle_sidebar"
		"click #sidebar-settings>[data-value=auto]" : "toggle_sidebar"

	initialize: (@options) ->
		@init_states()

	init_states: () ->
		@settingsState = local_storage('settings_state') || {
			sidebar: 'left',
			left_mini: false,
			background: 'dark',
			sidebarState: 'auto',
			displaySidebar: true
		}
		@apply_states()

	apply_states: () ->
		if @settingsState['left_mini']
			@toggleIcons()
		else
			@toggleAuto()
		local_storage('settings_state', @settingsState)

	toggle_sidebar: () ->
		@settingsState['left_mini'] = !@settingsState['left_mini']
		@apply_states()

	toggleAuto: (event) ->
		$(".logo").removeClass(ICON_CLASS)
		$(@$el).removeClass(ICON_CLASS)
		@$(".side-nav").removeClass(ICON_CLASS)
		@$(".attention").show()
		$(".wrap").removeClass(ICON_CLASS)
		$(window).trigger('resize')

	toggleIcons: (event) ->
		$(".logo").addClass(ICON_CLASS)
		$(@$el).addClass(ICON_CLASS)
		@$(".side-nav").addClass(ICON_CLASS)
		@$(".attention").hide()
		$(".wrap").addClass(ICON_CLASS)
		$(window).trigger('resize')

		
root.LeftSideBar = LeftSideBar