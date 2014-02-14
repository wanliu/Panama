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
		$(@$el).removeClass(ICON_CLASS)
		@$(".side-nav").removeClass(ICON_CLASS)
		@$(".attention").show()
		$(".wrap").removeClass(ICON_CLASS)
		@$(".lv2_categories").css('left', @$("#category-sidebar").width())
		$(window).trigger('resize')

	toggleIcons: (event) ->
		$(@$el).addClass(ICON_CLASS)
		@$(".side-nav").addClass(ICON_CLASS)
		@$(".attention").hide()
		$(".wrap").addClass(ICON_CLASS)
		@$(".lv2_categories").css('left', @$("#category-sidebar").width())
		$(window).trigger('resize')


class CategoryTree extends Backbone.View
	events:
		"click >a"                  : "toggle_tree"
		"mouseenter #forms-collapse>li"         : "show_children"
		"mouseleave #forms-collapse>li"         : "hide_children"
		"mouseleave .lv2_categories": "hide_categories"

	initialize: () ->
		@$(".icon-caret-right").remove()
		# @$("#forms-collapse").children().css("color","rgba(217, 255, 205, 0.77)")
		# @$(".accordion-group >ul").css("color","white")

	toggle_tree: (event) ->
		@$("#forms-collapse").toggle()
		@$(".lv2_categories").css('left', @$el.width())
		$("#left_sidebar").toggleClass('category-expanded')

	show_children: (event) ->
		@$($(event.target).attr('href')).show()

	hide_children: (event) ->
		@$($(event.target).attr('href')).hide()

	hide_categories: (event) ->
		clearTimeout(@time_id) unless _.isEmpty(@time_id)
		event_el = $(event.target)
		@time_id = setTimeout () =>
			event_el.hide()
		, 300


root.LeftSideBar = LeftSideBar
root.CategoryTree = CategoryTree
