root = (window || @)

class SideBar extends Backbone.View

	events: 
		"click #sidebar-settings>[data-value=icons]": "toggleIcons"
		"click #sidebar-settings>[data-value=auto]": "toggleAuto"

	ICON_CLASS = "sidebar-icons"

	initialize: (@options) ->
		@settingsState = JSON.parse(localStorage.getItem("settings-state")) || {
            sidebar: 'left',
            background: 'dark',
            sidebarState: 'auto',
            displaySidebar: true
        }

	toggleAuto: (event) ->
		$(".logo").removeClass(ICON_CLASS)
		$(@$el).removeClass(ICON_CLASS)
		@$("#side-nav").removeClass(ICON_CLASS)
		$(".wrap").removeClass(ICON_CLASS)
		$(window).trigger('resize')

	toggleIcons: (event) ->
		$(".logo").addClass(ICON_CLASS)
		$(@$el).addClass(ICON_CLASS)
		@$("#side-nav").addClass(ICON_CLASS)
		$(".wrap").addClass(ICON_CLASS)
		$(window).trigger('resize')
		
root.SideBar = SideBar