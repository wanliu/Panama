root = (window || @)

class FriendsContainerView extends RealTimeContainerView
	top_tip:
		klass   : "icon-group"
		tool_tip: "show messages"

	initialize: () ->
		super
		$(@el).append('<div class="notices-list"></div>')
		@followers_view = new FollowersView(parent_view: @)
		@set_default_view(@followers_view)

		@stranger_view  = new StrangersView(parent_view: @)

	set_default_view: (view) ->
		view.seted_default()
		@default_view = view

	bind_items: () ->
		# @client = Realtime.client(@realtime_url)
		@client = window.clients
		@client.receive_message @token, (message) =>
			@process_message message

	process_message: (message) ->
		@followers_view.process(message) || @stranger_view.process(message)


class FollowersView extends Backbone.View
	className: "followings-list"

	template:
    '<h5 class="tab-header followings">
			<i class="icon-group"></i>
			 我关注的[<span class="num">0</span>]
		</h5>
		<ul class="users-list followings">
		</ul>'

	initialize: () ->
		@parent_view  = @options.parent_view
		@$parent_view = $(@options.parent_view.el)

		@collection = new Backbone.Collection()
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)

		@render()

	render: () ->
		$(@el).html(@template)

	seted_default: () ->
		@is_default_view = true
		# @$parent_view.append(@el)
		@parent_view.$('div.notices-list').append(@el)
		@init_fetch()

	init_fetch: () ->
		@collection.fetch(url: "/users/followings")

	addAll: () ->
		@$("ul").html('')
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		if model.attributes.follow_type == "User"
			@$("h5 .num").html(@collection.length)
			friend_view = new FriendView({ model: model, parent_view: @ })
			model.view  = friend_view
			@$(".users-list").prepend(friend_view.render().el)

	process: (message) ->
		exist_model = @find_exist(message)
		if exist_model
			@top(exist_model)
			true
		else
			false

	find_exist: (model) ->
		_.find @collection.models, (item) ->
			item.get("follow_id") is model.send_user_id

	top: (model) ->
		@parent_view.active()
		friend_view = model.view
		friend_view.remove()
		@$("ul").prepend(friend_view.el)
		friend_view.delegateEvents()
		friend_view.active()


class StrangersView extends FollowersView
	template:
    '<h5 class="tab-header strangers">
			<i class="icon-group"></i>
			 陌生人[<span class="num">0</span>]
		</h5>
		<ul class="users-list strangers">
		</ul>'

	init_fetch: () ->

	addOne: (model) ->
		if @collection.length is 1 and @parent_view.$('.strangers').length is 0
			# @$parent_view.append(@el)
			@parent_view.$('div.notices-list').append(@el)
		super

	process: (message) ->
		model = new Backbone.Model()
		model.fetch
			url: "/users/#{message.send_user_id}"
			success: (model) =>
				@addStranger(model)

	addStranger: (model) ->
		exist_model = @find_exist(model)
		if exist_model
			@top(exist_model)
			true
		else
			@collection.add(model)
			@top(model)


	find_exist: (model) ->
		_.find @collection.models, (item) ->
			item.id is model.id


class FriendView extends Backbone.View
	tagName: 'li'

	events:
		"click" : "talk_to_friend"

	render: () ->
		html = @template(model: @model)
		$(@el).html(html)
		# $(@el).append(@talking_message_modal)
		@

	talk_to_friend: () ->
		@undo_active()
		if @$iframe
			@$iframe.show()
		else
			@init_and_show_iframe()

	active: () ->
		if !@$iframe || @$iframe.is(":hidden")
			$(@el).addClass('active')

	undo_active: () ->
		$(@el).removeClass('active')

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
		@$iframe.children("iframe").attr("src", "/chat_messages/dialogue/generate_and_display/#{friend_id}")

	template: _.template(
		"<img src='/default_img/t5050_default_avatar.jpg' class='pull-left img-circle' />
		<div class='user-info hide'>
			<div class='name'>
				<a href='#''><%= model.get('name') || model.get('login') %></a>
			</div>
			<div class='type'><%= model.get('follow_type') || 'User' %></div>
		</div>")


root.FriendsContainerView = FriendsContainerView
root.FriendView = FriendView