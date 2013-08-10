root = (window || @)

class FriendsContainerView extends ContainerView
	template: () ->
		""

	initialize: () ->
		super
		@followers_view = new FollowersView(parent_view: @)

		@set_default_view(@followers_view)

	set_default_view: (view) ->
		view.seted_default()
		@default_view = view

	bind_item: () ->
		@client = Realtime.client(@faye_url)
		@client.receive_message @token, (message) =>
			@process_message message

	process_message: (message) ->
	# sender = @collection.find (model) ->
	# 		model.get('follow_id') == message.send_user_id
	# 	if sender
	# 		@top(sender)
	# 	else
	# 		model = new Backbone.Model()
	# 		model.fetch
	# 			url: "/users/#{message.send_user_id}"
	# 			success: (model) =>
	# 				# @collection.add(model)
	# 				@addStranger(model)
		@default_view.process(message) || @stranger_view.process(message)


class FollowersView extends Backbone.View
	template:
        '<h5 class="tab-header followings">
			<i class="icon-group"></i> 我关注的[<span class="num">0</span>]
		</h5>
		<ul class="notices-list users-list followings">
		</ul>'

	initialize: () ->
		@$parent_view = $(@options.parent_view.el)
		@collection = new Backbone.Collection()
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@render()

	render: () ->
		$(@el).html(@template)

	seted_default: () ->
		@is_default_view = true
		@$parent_view.append(@el)
		@collection.fetch(url: "/users/followings")

	addAll: () ->
		@$("ul").html('')
		@$("h5 .num").html(@collection.length)
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		friend_view = new FriendView({ model: model, parent_view: @ })
		model.view  = friend_view
		@$(".users-list").prepend(friend_view.render().el)

	process: (message) ->
		exist_model = @include(message) ->
			model.get('follow_id') == message.send_user_id
		if exist_model
			@top(sender)

	include: (model) ->
		_.find @collection.models, (item) ->
			item.get("follow_id") is model.send_user_id

	top: (model) ->
		

class StrangersView extends Backbone.View
	template:
        '<h5 class="tab-header strangers">
			<i class="icon-group"></i> 陌生人[<span class="num">0</span>]
		</h5>
		<ul class="notices-list users-list strangers">
		</ul>'

	initialize: () ->
		@$parent_view = $(@options.parent_view.el)
		@collection = new Backbone.Collection()
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@render()

	render: () ->
		$(@el).html(@template)

	seted_default: () ->
		@is_default_view = true
		@$parent_view.append(@el)
		# @collection.fetch(url: "/users/followings")

	addAll: () ->
		@$("ul").html('')
		@$("h5 .num").html(@collection.length)
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		friend_view = new FriendView({ model: model, parent_view: @ })
		model.view  = friend_view
		@$(".users-list").prepend(friend_view.render().el)


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