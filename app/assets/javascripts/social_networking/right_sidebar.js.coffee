# var right_bar = new RightSideBar({el: ".right-sidebar"})
# 容器视图
# var message_view = { top : { title: "messages",
 #                             klass: "this-class", 
 #                             tool_tip: "show messages" 
 # 							  },  #顶部按钮
# 					   		   container_view : MessageContainerView }    # 容器container view
# 注册容器视图
# right_bar.register(message_view)

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

	register: (container) ->
		container_id      = _.uniqueId('sidebar_')
		container_options = _.extend(container, { id: container_id, parent_view: @ })
		container_view    = new container.container_view(container_options)
		@add_top(container, container_id)
		@add_container(container_view)
		container_view.active() unless @any_active_view()

	toggleIcons: (e) ->
		$("body").addClass('right-mini')
		$(window).trigger('resize')

	toggleAuto: (e) ->
		$("body").removeClass('right-mini')
		$(window).trigger('resize')

	add_top: (container, id)->
		top = container.top || {}
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

	fill_header: () ->

	bind_items: () ->


root.RightSideBar = RightSideBar
root.ContainerView = ContainerView
