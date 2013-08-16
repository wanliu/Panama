root = window || @

class NotificationsContainerView extends RealTimeContainerView
	top_tip:
		klass   : "icon-star"
		tool_tip: "显示消息通知"

	initialize: () ->
		super
		@transactions_view = new TransactionContainerView(parent_view: @)
		@activities_view = new ActivitiesContainerView(parent_view: @)
		@bind_realtime()

	bind_realtime: () ->
		@client = Realtime.client(@realtime_url)
		@client.monitor_people_notification @token, (info) =>
			if info.type == "OrderTransaction" || info.type == "OrderRefund"
				@transactions_view.realtime_help(info)
			else if info.type == "Activity"
				@activities_view.realtime_help(info)


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
		@collection.bind('reset', @add_all, @)
		@collection.bind('add', @add_one, @)
		@urlRoot = "/people/#{@current_user_login}/notifications"
		@collection.fetch(url: "#{@urlRoot}/unread?type=OrderTransaction")

	realtime_help: (info) ->
		@collection.add(info.value)
		@top(model)

	add_all: (collecton) ->
		@collection.each (model) =>
			if model.attributes.targeable_type == "OrderTransaction"
				@add_one(model)

	add_one: (model) ->
		@$("h5 .num").html(@collection.length)
		message_view = new TransactionMessageView({ model: model, parent_view: @ })
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
		window.location.replace(@model.get('url'))

	active: () ->
		$(@el).addClass('active')


class ActivitiesContainerView extends RealTimeContainerView

	bind_items: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)
		@$parent_view.append(@el)

		@urlRoot = "/people/#{@current_user_login}/notifications"
		@collection = new Backbone.Collection()
		@collection.bind('reset', @add_all, @)
		@collection.bind('add', @add_one, @)
		@collection.fetch({ url: "#{@urlRoot}/unread?type=Activity" })

	realtime_help: (info) ->
		@collection.add(info.value)

	fill_header: () ->
		$(@el).prepend('<h5 class="tab-header activities">
			<i class="icon-star"></i>活动消息[<span class="num">0</span>]
			</h5>
			<ul class="notices-list activities-list activities">
			</ul>')

	add_all: (collecton) ->
		@collection.each (model) =>
			@add_one(model)

	add_one: (model) ->
		@$("h5 .num").html(@collection.length)
		model.url = "#{@urlRoot}/#{model.id}"
		activity_view = new ActivityMessageView({ model: model, parent_view: @ })
		model.view = activity_view
		@$(".activities-list").prepend(activity_view.render().el)
		activity_view.bind("remove_model", _.bind(@remove_one, @))

	remove_one: (id) ->
		model = @collection.get(id)
		@collection.remove model if model?
		@$("h5 .num").html(@collection.length)


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

	show_modal: () ->
		activity_model = new ActivityModel({ 
			id: @model.get('targeable_id') 
		})
		activity_model.fetch success: (model) =>
			new ActivityView({
				model    : model 
			}).modal()
			@remove()    

	render: () ->
		$(@el).html(@template(model: @model))
		@

	remove: () ->
		$.ajax(
			type: "GET",
			dataType: "json",
			url: "#{@model.url}/enter",
			success: () =>
				@trigger("remove_model", @model.id)
		)
		super


root.NotificationsContainerView = NotificationsContainerView 