root = (window || @)

class FriendsContainerView extends ContainerView
	initialize: () ->
		@followings = []
		@strangers  = []
		@contacted  = []
		super
		@$("ul.users-list").addClass("followings")

	fill_header: () ->
		$(@el).prepend(
        '<h5 class="tab-header followings">
			<i class="icon-group"></i> 我关注的[<span class="num">0</span>]
		</h5>')
		@fill_modal()

	bind_items: () ->
		@collection = new Backbone.Collection()
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@collection.fetch(url: "/users/followings")

		@client = Realtime.client(@faye_url)
		@client.receive_message @token, (message) =>
			sender = @collection.find (model) ->
				model.get('follow_id') == message.send_user_id
			if sender
				@top(sender)
			else
				model = new Backbone.Model()
				model.fetch
					url: "/users/#{message.send_user_id}"
					success: (model) =>
						# @collection.add(model)
						@addStranger(model)

	top: (model) ->
		friend_view = model.view
		friend_view.remove()
		if @is_follwing(model)
			@$("ul.users-list.followings").prepend(friend_view.el)
		else if @is_stranger(model)
			@$("ul.users-list.strangers").prepend(friend_view.el)
		friend_view.delegateEvents()
		@active()
		friend_view.active()

	addAll: (collection) ->
		@$(".users-list").html('')
		@collection.each (model) =>
			@followings.push model
			@$(".followings .num").html(@followings.length)
			@addOne(model)

	addOne: (model) ->
		friend_view = new FriendView({ model: model, parent_view: @ })
		model.view  = friend_view
		@$(".users-list").prepend(friend_view.render().el)

	addStranger: (model) ->
		if @$("h5.strangers").length isnt 0
			@$(".strangers .num").html(@followings.length)
		else
			$(@el).append(
				'<h5 class="tab-header strangers">
					<i class="icon-group"></i> 陌生人[<span class="num">0</span>]
				</h5><ul class="notices-list users-list strangers">')

		if @is_stranger(model)
			exist_model = _.find @strangers, (item) ->
				item.id is model.id
			@top(exist_model)
		else
			@strangers.push model
			@addOneStranger(model)
			@$(".strangers .num").html(@strangers.length)


	addOneStranger: (model) ->
		friend_view = new FriendView({ model: model, parent_view: @ })
		model.view  = friend_view
		@$(".users-list.strangers").prepend(friend_view.render().el)


	fill_modal: () ->
		$('body').append(@talking_message_modal)

	is_follwing: (model) ->
		_.any @followings, (item) ->
			item.get('id') is model.id

	is_stranger: (model) ->
		_.any @strangers, (item) ->
			item.get('id') is model.id

	is_contacted: (model) ->
		_.any @contacted, (item) ->
			item.get('id') is model.id

	talking_message_modal: '<div class="modal hide fade message-talk-box">
		  <div class="modal-header">
		    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		    <h3><img src="/default_img/t5050_default_avatar.jpg" />sss</h3>
		  </div>
		  <div class="modal-body">
		    <p>One fine body…</p>
		  </div>
		  <div class="modal-footer">
		    <a href="#" class="btn">Close</a>
		    <a href="#" class="btn btn-primary">Save changes</a>
		  </div>
		</div>'

class FriendView extends Backbone.View
	tagName: 'li'

	events:
		"click" : "talk_to_friend"

	render: () ->
		html = @template(model: @model)
		$(@el).html(html)
		$(@el).append(@talking_message_modal)
		@

	talk_to_friend: () ->
		@undo_active()
		if @$iframe
			@$iframe.show()
		else
			@init_and_show_iframe()

	active: () ->
		$(@el).css('background-color', 'orange')

	undo_active: () ->
		$(@el).css('background-color', '')

	init_and_show_iframe: () ->
		@$iframe= $(@make("div"))
		@$iframe.addClass("chat_dialogue_panel")
		@$iframe.css("left", "5px")

		@$iframe.append(
            "<iframe></iframe>
				<a class='close_label' href='javascript:void(0)'></a>")

		@$iframe.children("a.close_label").click (e) =>
			@$iframe.hide()

		$("body").append(@$iframe)

		friend_id = @model.get('follow_id') || @model.get("id")
		@$iframe.children("iframe").attr("src", "/chat_messages/dialogue/generate_and_display/#{ friend_id }")

	template: _.template(
        "<img src='/default_img/t5050_default_avatar.jpg' class='pull-left img-circle' />
	    <div class='user-info'>
	      <div class='name'><a href='#''><%= model.get('name') || model.get('login') %></a></div>
	        <div class='type'><%= model.get('follow_type') || 'User' %></div>
	    </div>")

root.FriendsContainerView = FriendsContainerView