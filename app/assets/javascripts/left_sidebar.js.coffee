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
		# $(".logo").removeClass(ICON_CLASS)
		$(@$el).removeClass(ICON_CLASS)
		@$(".side-nav").removeClass(ICON_CLASS)
		@$("#category-sidebar").show()
		@$(".attention").show()
		$(".wrap").removeClass(ICON_CLASS)
		$(window).trigger('resize')

	toggleIcons: (event) ->
		# $(".logo").addClass(ICON_CLASS)
		$(@$el).addClass(ICON_CLASS)
		@$(".side-nav").addClass(ICON_CLASS)
		@$("#category-sidebar").hide()
		@$(".attention").hide()
		$(".wrap").addClass(ICON_CLASS)
		$(window).trigger('resize')


class CategoryTree extends Backbone.View
	events:
		"click >a"                  : "toggle_tree"
		"mouseenter >ul>li"         : "show_children"
		"mouseleave >ul>li"         : "hide_children"
		"mouseleave .lv2_categories": "hide_categories"

	initialize: () ->
		@$(".icon-caret-right").remove()
		@$("#forms-collapse").children().css("color","rgba(217, 255, 205, 0.77)")
		@$(".accordion-group >ul").css("color","white")

	toggle_tree: (event) ->
		@$("#forms-collapse").toggle()

	show_children: (event) ->
		@$($(event.target).attr('href')).show()

	hide_children: (event) ->
		@$($(event.target).attr('href')).hide()

	hide_categories: (event) ->
		setTimeout () =>
			$(event.target).hide()
		, 300

		
root.LeftSideBar = LeftSideBar
root.CategoryTree = CategoryTree
