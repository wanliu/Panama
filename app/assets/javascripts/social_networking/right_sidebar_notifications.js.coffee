root = window || @

class NotificationsContainerView extends RealTimeContainerView
	top_tip:
		klass   : "icon-star"
		tool_tip: "显示消息通知"

	initialize: () ->
		super
		@transactions_view = new TransactionContainerView(parent_view: @)
		@activities_view = new ActivitiesContainerView(parent_view: @)


class TransactionContainerView extends RealTimeContainerView
	fill_header: () ->
		$(@el).prepend(
				'<h5 class="tab-header transactions">
			<i class="icon-edit"></i>交易消息[<span class="num">0</span>]
		</h5>
		<ul class="notices-list transactions-list transactions">
		</ul>')

	bind_items: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)
		@$parent_view.append(@el)

		@collection = new Backbone.Collection
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@urlRoot = "/people/#{@current_user_login}/notifications"
		@collection.fetch(url: "#{@urlRoot}/unread?type=OrderTransaction")
		@bind_realtime()

	bind_realtime: () ->
		@client = Realtime.client(@realtime_url)
		@client.monitor_people_notification @token, (info) =>
			model = info.value
			if info.type == "OrderTransaction" || info.type == "OrderRefund"
				@collection.add(model)
				@top(model)

	addAll: (collecton) ->
		@collection.each (model) =>
			if model.attributes.targeable_type == "OrderTransaction"
				@addOne(model)

	addOne: (model) ->
		@$("h5 .num").html(@collection.length)
		message_view = new TransactionMessageView({ 
			login: @current_user_login,
			model: model, 
			parent_view: @ })
		model.view  = message_view
		@$(".transactions-list").prepend(message_view.render().el)

	top: (model) ->
		@active()
		exsited_model = _.find @collection.models, (item) ->
			item.id is model.id
		exsited_model.view.active() if exsited_model && exsited_model.view


class TransactionMessageView extends FriendView
	tagName: 'li'

	events:
		"click" : "direct_to_transaction_detail"

	template: (options) ->
		_.template("<i class=' icon-volume-up'></i>
					<img src='<%= model.get('targeable').img_url %>' class='pull-left img-circle' />
					<%= model.get('body') %>,点击查看详情")(options)

	direct_to_transaction_detail: () ->
		@undo_active()
		@notification_id = @model.get('id')
		$.ajax({
			type: "put",
			dataType: "json",
			data:{ id : @notification_id}
			url: "/people/#{@options.login}/notifications/read_notification"
			success: () =>
				window.location.replace(@model.get('url'))
		})
		
		

	active: () ->
		$(@el).addClass('active')


class ActivitiesContainerView extends RealTimeContainerView

	bind_realtime: () ->
		@client = Realtime.client(@realtime_url)
		@client.subscribe "/Activity/un_dispose", (info) =>
			@realtime_help(info, 'activities')

	realtime_help: (info, type) ->
		data = info.value
		switch info.type
			when "new"
				@collection.add(_.extend(data, {_type: type}))

	fill_header: () ->
		$(@el).prepend('<h5 class="tab-header activities">
			<i class="icon-star"></i>活动消息[<span class="num">0</span>]
			</h5>
			<ul class="notices-list activities-list activities">
			</ul>')

	bind_items: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)
		@$parent_view.append(@el)
		@bind_realtime()

		@urlRoot = "/people/#{@current_user_login}/notifications"
		@collection = new Backbone.Collection()
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@collection.fetch({ url: "#{@urlRoot}/unread?type=Activity" })

	addAll: (collecton) ->
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		@$("h5 .num").html(@collection.length)
		model.url = "#{@urlRoot}/#{model.id}"
		activity_view = new ActivityMessageView({ model: model, parent_view: @ })
		model.view = activity_view
		@$(".activities-list").prepend(activity_view.render().el)
		activity_view.bind("remove_model", _.bind(@remove_model, @))

	remove_model: (id) ->
		model = @collection.get(id)
		@collection.remove model if model?   


class ActivityMessageView extends Backbone.View
	tagName: 'li'
	template: _.template(
				"<img src='<%= model.get('targeable').img_url %>' class='pull-left img-circle' />
			<div class='user-info'>
			<div class='name'>
				<a href='#''><%= model.get('body') %></a>
			</div>
			<div class='type'><%= model.get('targeable').title %></div>
			</div>")

	events:
		"click" : "show_modal"

	initialize: () ->
		@$el = $(@el)
		@model.bind('remove', @remove, @)

	show_modal: () ->
		activity_model = new ActivityModel({ 
			id: @model.get('targeable_id') 
		})
		activity_model.fetch success: (model) =>
			new ActivityView({
				model    : model 
			}).modal()     
			@trigger("remove_model", @model.id)

	render: () ->
		$(@el).html(@template(model: @model))
		@

	remove: () ->
		$.ajax(
			type: "GET",
			dataType: "json",
			url: "#{@model.url}/enter"
		)
		super


root.NotificationsContainerView = NotificationsContainerView 