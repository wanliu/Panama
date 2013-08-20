root = window || @

class NotificationsContainerView extends RealTimeContainerView
	top_tip:
		klass   : "icon-star"
		tool_tip: "显示消息通知"

	bind_realtime: () ->
		@client = Realtime.client(@realtime_url)
		@client.monitor_people_notification @token, (info) =>
			if info.type == "Activity"
				@activities_view.realtime_help(info)
			else
				@transactions_view.realtime_help(info)

	bind_items: () ->
		@urlRoot = "/people/#{@current_user_login}/notifications"
		@transactions_view = new TransactionsContainerView(parent_view: @)
		@activities_view = new ActivitiesContainerView(parent_view: @)
		@collection = new Backbone.Collection
		@collection.bind('reset', @add_all, @)
		@collection.fetch(url: "#{@urlRoot}/unreads")
		@bind_realtime()

	add_all: () ->
		@collection.each (model) =>
			if model.attributes.targeable_type == "Activity"
				@activities_view.collection.add(model)
			else
				@transactions_view.collection.add(model)
		new TransactionsChatRemind(parent_view: @)




class TransactionsContainerView extends NotificationsContainerView
	fill_header: () ->
		$(@el).prepend(
		    '<h5 class="tab-header transactions">
			    <i class="icon-edit"></i>交易消息[<span class="num">0</span>]
		    </h5>
		    <ul class="notices-list transactions-list transactions"></ul>')

	bind_items: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)
		@$parent_view.append(@el)
		@collection = new Backbone.Collection
		@collection.bind('add', @add_one, @)


	realtime_help: (info) ->
		@collection.add(info.value)
		@active()
		@top(model)

	add_one: (model) ->
		@$("h5 .num").html(@collection.length)
		model.url = "#{@parent_view.urlRoot}/#{model.id}"
		message_view = new TransactionMessageView({ 
			model: model, 
			parent_view: @ })
		model.view  = message_view
		@$(".transactions-list").prepend(message_view.render().el)

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
		_.template("<img src='<%= model.get('targeable').img_url %>' class='pull-left img-circle' />
					<div class='user-info'>
						<i class=' icon-volume-up'></i>
						<%= model.get('body') %>,点击查看详情
					</div>")(options)

	direct_to_transaction_detail: () ->
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

	bind_items: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)
		@$parent_view.append(@el)
		@collection = new Backbone.Collection
		@collection.bind('add', @add_one, @)

	realtime_help: (info) ->
		@collection.add(info.value)

	fill_header: () ->
		$(@el).prepend('<h5 class="tab-header activities">
			<i class="icon-star"></i>活动消息[<span class="num">0</span>]
			</h5>
			<ul class="notices-list activities-list activities">
			</ul>')

	add_one: (model) ->
		@$("h5 .num").html(@collection.length)
		model.url = "#{@parent_view.urlRoot}/#{model.id}"
		activity_view = new ActivityMessageView({ 
			model: model, 
			parent_view: @ })
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
			type: "POST",
			dataType: "json",
			url: "#{@model.url}/mark_as_read",
			success: () =>
				@trigger("remove_model", @model.id)
		)
		super

root.NotificationsContainerView = NotificationsContainerView 