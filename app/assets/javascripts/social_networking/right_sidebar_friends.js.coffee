root = (window || @)

class FriendsContainerView extends RealTimeContainerView
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
		Caramal.MessageManager.on('channel:new', (channel) =>
			console.log(channel)
			# @process_message channel
		)

	process_message: (channel) ->
		@followers_view.process(channel) || @stranger_view.process(channel)


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
		# if model.attributes.follow_type == "User"
		@$("h5 .num").html(@collection.length)
		friend_view = new FriendView({ model: model, parent_view: @ })
		model.view  = friend_view
		@$(".users-list").prepend(friend_view.render().el)

	process: (channel) ->
		exist_model = @find_exist(channel)
		if exist_model
			@top(exist_model)
			true
		else
			false

	find_exist: (channel) ->
		_.find @collection.models, (item) ->
			item.get("name") is channel.user

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

	process: (channel) ->
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

	template: _.template(
		"<img src='/default_img/t5050_default_avatar.jpg' class='pull-left img-circle' />
		<div class='user-info hide'>
			<div class='name'>
				<a href='#''><%= model.get('name') || model.get('login') %></a>
			</div>
			<div class='type'><%= model.get('follow_type') || 'User' %></div>
		</div>")

	render: () ->
		html = @template(model: @model)
		$(@el).html(html)
		@

	talk_to_friend: () ->
		@unactive()
		if @chat
			$(@chat.el).show()
		else
			@new_chat()

	new_chat: () ->
		@chat = new ChatView({user: @model.get('name')})
		@chat.bind("active_avatar", _.bind(@active, @))
		@chat.bind("unactive_avatar", _.bind(@unactive, @))
		$("body").append(@chat.el)

	active: () ->
		# if !@chat || $(@chat.el).is(":hidden")
		$(@el).addClass('active')

	unactive: () ->
		$(@el).removeClass('active')


root.FriendsContainerView = FriendsContainerView
root.FriendView = FriendView