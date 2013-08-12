#= require lib/realtime_client
root = window || @
class TransactionView extends ContainerView

	template: () -> ""

	fill_header: () ->
		$(@el).prepend(
        '<h5 class="tab-header">
			<i class="icon-edit"></i> 交易消息[<span class="num">0</span>]
		</h5>
		<ul class="notices-list users-list followings">
		</ul>')

	bind_items: () ->
		@collection = new Backbone.Collection
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		# @collection.fetch(url: "/people/#{@current_user_login}/notifications")

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
		message_view = new TransactionMessageView({ model: model, parent_view: @ })
		model.view  = message_view
		@$(".users-list").prepend(message_view.render().el)

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
		# _.template("<i class=' icon-volume-up'></i>
  #       			<%= model.get('body') %>,点击<a href='<%= model.get('url') %>'>这里</a>查看详情")(options)
		_.template("<i class=' icon-volume-up'></i>
					<%= model.get('body') %>,点击查看详情")(options)


	direct_to_transaction_detail: () ->
		@undo_active()
		window.location.replace(@model.get('url'))

	active: () ->
		$(@el).addClass('active')




root.TransactionView = TransactionView