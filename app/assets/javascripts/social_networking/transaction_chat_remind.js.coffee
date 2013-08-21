root = window || @
class TransactionsChatRemind extends Backbone.View
	tagClass: '.transactions-list'

	initialize: ()->
		@realtime_url = @options.parent_view.realtime_url
		@token = @options.parent_view.token
		@current_user_login = @options.parent_view.current_user_login
		@bind_realtime()
		@bind_items()

	bind_items: () ->
		@collection = new Backbone.Collection
		@collection.bind('reset', @add_all, @)
		@collection.bind('add', @add_one, @)
		@collection.fetch(url: "/people/#{@current_user_login}/transactions/unread_messages")

	bind_realtime: () ->
		@client = Realtime.client @realtime_url
		@client.subscribe @receive_notice_url(), (message) =>
			msg = _.extend({count: 1} , message)
			model = @collection.where(owner_id: msg.owner_id, owner_type: msg.owner_type )[0]
			if model?
				model.set({count: model.get('count')+msg.count, content: msg.content })
			else
				@collection.add(msg)

	receive_notice_url: () ->
		"/transaction/chat/message/#{@token}"

	add_all: () ->
		@collection.each (model) =>
			@add_one(model)

	add_one: (model) ->
		remind_view = new TransactionChatRemindView({ 
			model: model, 
			parent_view: @ })
		model.view  = remind_view
		$(".transactions-list").prepend(remind_view.render().el)
				

class TransactionChatRemindView extends Backbone.View
	tagName: "li"
	events:
		"click" : "message_handle"

	initialize: () ->
		@current_user_login =  @options.parent_view.current_user_login
		@model.bind("change:count", @change_count, @)
		@model.bind("change:content", @change_content, @)

	template: (options) ->
		_.template("<li id=<%= model.get('owner_id') %> >
						<img src='<%= model.get('send_user').avatar_url %>' class='pull-left img-circle' />
						<div class='user-info'>
							<span class='badge badge-important count'>
								<%=model.get('count') %>
	    					</span>
							<span class='content'>
								<%= model.get('content') %>
							</span>
						</div></li>")(options)

	change_count: () ->
		@$(".count").html(@model.get('count'))

	change_content: () ->
		@$(".content").html(@model.get('content'))

	render: () ->
		$(@el).html(@template(model: @model))
		@

	message_handle: () ->
		$.ajax({
			type: "post",
			dataType: "json",
			data:{owner_type: @model.get('owner_type')}
			url: "/people/#{@current_user_login}/transactions/#{ @model.get('owner_id')}/mark_as_read",
			success: (data) =>
					window.location.replace(data.url)
					_this.$el.remove()
		})

root.TransactionsChatRemind = TransactionsChatRemind