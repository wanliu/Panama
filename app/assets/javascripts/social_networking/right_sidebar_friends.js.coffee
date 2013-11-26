root = (window || @)

class root.FriendsContainerView extends RealTimeContainerView
  events:
    'keyup input.filter_key' : 'filter_users'

  initialize: () ->
    super
    @followers_view = new FollowersView(parent_view: @)
    @stranger_view  = new StrangersView(parent_view: @)
    @set_default_view(@followers_view)
    $(@el).prepend('
      <div class="fixed_head">
        <input class="filter_key" type="text"/>
      </div>')

  set_default_view: (view) ->
    view.seted_default()
    @default_view = view

  bind_items: () ->
    Caramal.MessageManager.on('channel:new', (channel) =>
      @process_message(channel)
    )

  process_message: (channel) ->
    @followers_view.process(channel) || @stranger_view.process(channel)

  filter_users: (event) ->
    keyword = $(event.target).val().trim()
    @followers_view.filter_users(keyword)
    @stranger_view.filter_users(keyword)


class FollowersView extends Backbone.View
  className: "followings-list"

  template:
    '<h5 class="tab-header">
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
    @$parent_view.append(@el)
    @init_fetch()

  init_fetch: () ->
    @collection.fetch(url: "/users/followings")

  addAll: () ->
    @$("ul").html('')
    @collection.each (model) =>
      @addOne(model)

  addOne: (model) ->
    @$("h5 .num").html(@collection.length)
    friend_view = new FriendView({ model: model, parent_view: @ })
    model.view  = friend_view
    @$(".users-list").append(friend_view.render().el)

  process: (channel) ->
    exist_model = @find_exist(channel)
    if exist_model
      @top(exist_model)
      exist_model.view.setChannel(channel)
      true
    else
      false

  filter_users: (keyword) ->
    pattern = new RegExp(keyword)
    _.each @collection.models, (model) ->
      if keyword is ""
        $(model.view.el).show()
      else
        $(model.view.el).hide() unless pattern.test(model.get('login'))

  find_exist: (channel) ->
    _.find @collection.models, (model) ->
      model.get('login') is channel.user

  top: (model) ->
    @parent_view.active()
    friend_view = model.view
    friend_view.remove()
    @$("ul").append(friend_view.el)
    friend_view.delegateEvents()


class StrangersView extends FollowersView
  className: "strangers-list"

  template:
    '<h5 class="tab-header">
      <i class="icon-group"></i>
       陌生人[<span class="num">0</span>]
    </h5>
    <ul class="users-list strangers">
    </ul>'

  init_fetch: () ->

  addOne: (model) ->
    if @collection.length is 1 and @parent_view.$('.strangers').length is 0
      @$parent_view.find(".fixed_head").after(@el)
    super

  process: (channel) ->
    @channel = channel
    model = new Backbone.Model()
    model.fetch
      url: "/users/#{channel.user}"
      success: (model) =>
        @addStranger(model)
        model.view.setChannel(@channel)

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


class root.FriendView extends Backbone.View
  tagName: 'li'

  events:
    "click" : "talk_to_friend"

  template: _.template(
    "<img src='/default_img/t5050_default_avatar.jpg' class='pull-left img-circle' />
    <div class='user-info hide'>
      <div class='name'>
        <a href='#''><%= model.get('login') %></a>
      </div>
      <div class='type'><%= model.get('follow_type') %></div>
    </div>")

  render: () ->
    html = @template(model: @model)
    $(@el).html(html)
    @

  setChannel: (@channel) ->
    @channel ||= Caramal.Chat.of(@model.get('login'))
    @channel.open()
    @channel.onMessage (msg) =>
      unless @channel.isActive()
        @channel.message_buffer.push(msg)
        @active()
    , @

  talk_to_friend: () ->
    @unactive()
    $(".global_chat_panel").css('z-index', 9999)
    @setChannel() unless @channel?
    unless @chat_view 
      @chat_view = new ChatView({ user: @model.get('login'), channel: @channel })
      @bind_chat()
    @chat_view.showDialog()

  bind_chat: () ->
    @chat_view.bind("active_avatar", _.bind(@active, @))
    @chat_view.bind("unactive_avatar", _.bind(@unactive, @))

  active: () ->
    $(@el).addClass('active')

  unactive: () ->
    $(@el).removeClass('active')

