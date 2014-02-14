root = window || @

class NotificationsContainerView extends RealTimeContainerView
	top_tip:
		klass   : "icon-star"

	fill_header: () ->
		$(@el).prepend('
			<h5 class="tab-header">
				<i class="icon-edit"></i>消息通知[<span class="num">0</span>]
			</h5>')

	bind_items: () ->
		@bind_view()
		@bind_collection()
		@bind_realtime()

	bind_view: () ->
		@urlRoot = "/people/#{@current_user_login}/notifications"
		$(@el).append('<div class="notices-list"></div>')
		@transactions_view = new TransactionsContainerView(parent_view: @)
		@activities_view = new ActivitiesContainerView(parent_view: @)
		@tran_view = new TransactionsChatRemind(parent_view: @)

	bind_collection: () ->
		@views = [@transactions_view, @tran_view, @activities_view]
		_.each @views, (item) =>
			item.bind('add_count',@handle_number, @)
			item.bind('remove_count',@handle_number, @)
		@collection = new Backbone.Collection
		@collection.bind('reset', @add_all, @)
		@collection.fetch(url: "#{@urlRoot}/unreads")

	bind_realtime: () ->
		# @client = Realtime.client(@realtime_url)
		@client = window.clients
		@client.monitor_people_notification @token, (info) =>
			if info.type == "Activity"
				@activities_view.realtime_help(info)
			else
				@transactions_view.realtime_help(info)

	handle_number: (number = 0) ->
		_.each @views, (item) =>
			number += item.collection.length
		@$("h5 .num").html(number)

	add_all: () ->
		@collection.each (model) =>
			if model.attributes.targeable_type == "Activity"
				@activities_view.collection.add(model)
			else
				@transactions_view.collection.add(model)


class TransactionsContainerView extends NotificationsContainerView
	className: "transactions-list"

	fill_header: () ->
		$(@el).prepend('<ul class="transactions"></ul>')

	bind_items: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)
		@parent_view.$('div.notices-list').append(@el)
		@collection = new Backbone.Collection
		@collection.bind('add', @add_one, @)

	realtime_help: (info) ->
		model = info.value
		@collection.add(model)
		@active_one(model)
		@top(model)

	active_one: (model) ->
		@collection.get(model.id).view.active()

	add_one: (model) ->
		model.url = "#{@parent_view.urlRoot}/#{model.id}"
		message_view = new TransactionMessageView({
			model: model,
			parent_view: @ })
		model.view = message_view
		$("ul", @el).prepend(message_view.render().el)
		message_view.bind("remove_one", _.bind(@remove_one, @))
		@trigger("add_count")

	remove_one: (id)->
		model = @collection.get(id)
		@collection.remove model if model?
		@trigger("remove_count")

	top: (model) ->
		@parent_view.active()
		exsited_model = _.find @collection.models, (item) ->
			item.id is model.id
		exsited_model.view.active() if exsited_model && exsited_model.view


class TransactionMessageView extends Backbone.View
	tagName: 'li'

	events:
		"click" : "direct_to_transaction_detail"

	template: (options) ->
		_.template("
			<img src='<%= model.get('targeable').img_url %>' class='pull-left ' />
			<div class='transaction-info'>
				<i class=' icon-volume-up'></i>
				<%= model.get('body') %>,点击查看详情
			</div>")(options)

	direct_to_transaction_detail: () ->
		@trigger("remove_one", @model.id)
		$.ajax({
			type: "POST",
			dataType: "json",
			data:{ id : @model.id }
			url: "#{@model.url}/mark_as_read",
			success: () =>
				window.location.replace(@model.get('url'))
		})

	render: () ->
		$(@el).html(@template(model: @model))
		@


class ActivitiesContainerView extends NotificationsContainerView
	className: "activities-list"

	bind_items: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)
		@parent_view.$('div.notices-list').append(@el)
		@collection = new Backbone.Collection
		@collection.bind('add', @add_one, @)

	realtime_help: (info) ->
		model = info.value
		@collection.add(model)
		@active_one(model)

	active_one: (model) ->
		@collection.get(model.id).view.active()

	fill_header: () ->
		$(@el).prepend('<ul class="activities"></ul>')

	add_one: (model) ->
		model.url = "#{@parent_view.urlRoot}/#{model.id}"
		activity_view = new ActivityMessageView({
			model: model,
			parent_view: @ })
		model.view = activity_view
		$("ul", @el).prepend(activity_view.render().el)
		activity_view.bind("remove_model", _.bind(@remove_one, @))
		@trigger("add_count")

	remove_one: (id) ->
		model = @collection.get(id)
		@collection.remove model if model?
		@$("h5 .num").html(@collection.length)
		@trigger("remove_count")


class ActivityMessageView extends Backbone.View
	tagName: 'li'

	template: _.template("
		<img src='<%= model.get('targeable').img_url %>' class='pull-left ' />
		<div class='activity-info'>
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
			new ActivityView({model: model}).modal()
			@remove()
			$('.notices-list').mouseleave()

	active: () ->
		$(@el).addClass('active')

	render: () ->
		$(@el).html(@template(model: @model))
		@

	remove: () ->
		$.ajax(
			type: "POST",
			dataType: "json",
			url: "#{@model.url}/mark_as_read",
			success: () =>
				@trigger("remove_model", @model.id)
		)
		super


root.NotificationsContainerView = NotificationsContainerView