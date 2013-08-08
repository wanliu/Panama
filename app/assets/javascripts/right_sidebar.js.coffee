# var right_bar = new RightSideBar({el: ".right-sidebar"})
# 容器视图
# var message_view = { top       : { title: "messages", klass: "this-class", tool_tip: "show messages" },  #顶部按钮
# 					   heder_html: '<h5 class="tab-header"><i class="icon-group"></i> Last logged-in users</h5>', # 容器discription
# 					   container_view : MessageContainerView }    # 容器中的item-view
# 注册容器视图
# right_bar.register(message_view)


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
		container_options = _.extend(container, { id: container_id })
		container_view    = new container.container_view(container_options)
		@add_top(container, container_id)
		@add_container(container_view)
		debugger
		container_view.active() unless @any_active_view()

	toggleIcons: (e) ->
		$("body").addClass('right-mini')
		$(window).trigger('resize')

	toggleAuto: (e) ->
		$("body").removeClass('right-mini')
		$(window).trigger('resize')

	add_top: (container, id)->
		top = container.top || {}
		@$('ul.nav-tabs').append(
			"<li class='active'>
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
	template: (options) ->
		html = $("#right-sidebar-templates .container").html()
		html = html.replace("&lt;", "<").replace("&gt;", ">")
		_.template(html)(options)

	className: "tab-pane clearfix"

	initialize: () ->
		html = @template(header: (@options.header_html || ""))
		$(@el).html(html)
		$(@el).attr('id', @options.id)
		@fill_header()
		@bind_items()

	active: () ->
		$(@el).addClass("active");

	fill_header: () ->

	bind_items: () ->

class MessageContainerView extends ContainerView
	bind_items: () ->

class TransactionView extends ContainerView

	template1: "<ul><li><p>你购买的产品已经{{state}},点击
							<a href='/people/{{current_user}}/transactions/{{transaction_id}}'>这里</a>
							 查看详情<p></li></ul>"
	template2: "<li><p>你的订单买家已经{{state}},点击
	 						<a href='/shops/{{current_user}}/admins/transactions/{{transaction_id}}'>这里</a>
	 						 查看详情<p></li>"

	bind_items: () ->
		@collecton = new Backbone.Collection
		@collecton.bind('add', @addOne, @)
		# @collecton.add({state: "uncomplete", current_user: "xifengzhu",transaction_id: 4})
		@collecton.add({state: "completed", current_user: "SA",transaction_id: 7})

	addOne: (model) ->
		row_item = Hogan.compile(@template2)
		$(".body.tab-content").append(row_item.render(model.toJSON()))

root.RightSideBar = RightSideBar
root.ContainerView = ContainerView
root.MessageContainerView = MessageContainerView
root.TransactionView = TransactionView
