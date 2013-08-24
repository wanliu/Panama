# var right_bar = new RightSideBar({el: ".right-sidebar"})
# right_bar.register(ContainerView)

#= require lib/realtime_client
root = (window || @)

class RightSideBar extends Backbone.View
	template: () ->
		$("#right-sidebar-templates .main").html()

	events:
		"click #sidebar-settings>[data-value=icons]": "toggleIcons"
		"click #sidebar-settings>[data-value=auto]": "toggleAuto"

	initialize: () ->
		$(@el).html(@template())
		@register_counter = 0
		@toggleIcons()

	register: (containers...) ->
		for container in containers
			unless @is_registered(container)
				container_id   = _.uniqueId('sidebar_')
				container_view = new container({ id: container_id, parent_view: @ })
				@add_top(container_view, container_id)
				@add_container(container_view)

				@registered_containers[String(container)] = container_view
				container_view.active() unless @any_active_view()

	undo_register: (containers...) ->
		for container in containers
			if @is_registered(container)
				container_view = @registered_containers[String(container)]
				delete @registered_containers[String(container)]
				container_view.remove()

	is_registered: (container) ->
		@registered_containers ?= {}
		@registered_containers[String(container)]?

	toggleIcons: (e) ->
		$("body").addClass('right-mini')
		$(window).trigger('resize')

	toggleAuto: (e) ->
		$("body").removeClass('right-mini')
		$(window).trigger('resize')

	add_top: (container, id)->
		top = container.top_tip || {}
		top_li = @$('ul.nav-tabs').append(
			"<li>
				<a href='##{ id }' data-toggle='tab'>
					<i class='#{ if top.klass then top.klass else '' }'>
						#{ if top.title then top.title else '' }
					</i>
				</a>
			</li>")

	add_container: (container_view) ->
		@$(".body").append(container_view.el)

	any_active_view: () ->
		_.any @$('.body').children('div'), (div) ->
			$(div).hasClass('active')


class ContainerView extends Backbone.View
	too_tip: ""

	template: () ->
		$("#right-sidebar-templates .container").html()

	className: "tab-pane clearfix"

	initialize: () ->
		@parent_view = @options.parent_view

		html = @template()
		$(@el).html(html)

		@view_id = @options.id
		$(@el).attr('id', @view_id)

		@fill_header()
		@bind_items()

	active: () ->
		@active_header()
		@active_body()

	active_header: () ->
		_.each @parent_view.$('header li'), (li) =>
			href = "##{ @view_id }"
			if $(li).children('a').attr('href') == href
				$(li).addClass('active')
			else
				$(li).removeClass('active')

	active_body: () ->
		_.each @parent_view.$('.body').children('div'), (div) =>
			if $(div).attr('id') == @view_id
				$(div).addClass('active')
			else
				$(div).removeClass('active')

	remove: () ->
		@active_first_brother_when_deleted()
		@remove_header_li()
		super

	active_first_brother_when_deleted: () ->
		if $(@el).hasClass('active')
			containers = _.values @parent_view.registered_containers
			if containers.length > 0
				containers[0].active()
			else
				$(@parent_view.el).css('display', 'none')

	remove_header_li: () ->
		@parent_view.$("header li a[href=##{ @view_id }]").parent('li').remove()

	fill_header: () ->

	bind_items: () ->


class RealTimeContainerView extends ContainerView

RealTimeContainerView.bind_runtime = (options) ->
	_.extend(@prototype, options)



root.RightSideBar  = RightSideBar
root.ContainerView = ContainerView
root.RealTimeContainerView = RealTimeContainerView
