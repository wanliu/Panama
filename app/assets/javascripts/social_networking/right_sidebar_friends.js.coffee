root = (window || @)

class root.ChatContainerView extends RealTimeContainerView
  events:
    'keyup input.filter_key' : 'filter_list'

  initialize: () ->
    super
    @friends_view = new FriendsView(parent_view: @)
    @stranger_view  = new StrangersView(parent_view: @)
    @groups_view = new GroupsView(parent_view: @)
    $(@el).prepend('
      <div class="fixed_head">
        <input class="filter_key" type="text"/>
      </div>')

  bind_items: () ->
    Caramal.MessageManager.on('channel:new', (channel) =>
      console.log(channel)
      @process_message(channel)
    )

  process_message: (channel) ->
    @friends_view.process(channel) || @stranger_view.process(channel) || @groups_view.process(channel)

  filter_list: (event) ->
    keyword = $(event.target).val().trim()
    @friends_view.filter_list(keyword)
    @stranger_view.filter_list(keyword)
    @groups_view.filter_list(keyword)

class FriendsView extends Backbone.View
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
    @$parent_view.append(@el)
    @collection = new Backbone.Collection()
    @collection.bind('reset', @addAll, @)
    @collection.bind('add', @addOne, @)
    @init_fetch()
    @render()

  render: () ->
    $(@el).html(@template)
    @

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

  filter_list: (keyword) ->
    pattern = new RegExp(keyword)
    _.each @collection.models, (model) ->
      if pattern.test(model.get('login'))
        $(model.view.el).show()
      else
        $(model.view.el).hide()

  find_exist: (channel) ->
    _.find @collection.models, (model) ->
      model.get('login') is channel.user

  top: (model) ->
    @parent_view.active()
    friend_view = model.view
    friend_view.remove()
    @$("ul").append(friend_view.el)
    friend_view.delegateEvents()


class GroupModel extends Backbone.Model
  defaults: () ->
    { login: 'group_' + _.uniqueId() }

class GroupList extends Backbone.Collection
  model: GroupModel

class GroupsView extends FriendsView
  className: "groups-list"

  template:
    '<h5 class="tab-header">
      <i class="icon-group"></i>
       群组[<span class="num">0</span>]
    </h5>
    <ul class="users-list groups">
    </ul>'

  initialize: () ->
    super
    _.each [0..1], (i) =>
      @collection.add(new GroupModel({login: 'group_' + i }))

  init_fetch: () ->

  addOne: (model) ->
    groupView = new GroupView({ model: model, parent_view: @ })
    model.view  = groupView
    @$(".users-list").append(groupView.render().el)


class StrangersView extends FriendsView
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
    "click" : "showChat"

  template: _.template(
    "<span class='badge badge-important message_count'></span>
    <img src='/default_img/t5050_default_avatar.jpg' class='img-circle' />
    <div class='user-info hide'>
      <div class='name'>
        <a href='#''><%= model.get('login') %></a>
      </div>
      <div class='type'><%= model.get('follow_type') %></div>
    </div>")

  initialize: () ->
    @clearMsgCount()

  render: () ->
    html = @template(model: @model)
    $(@el).html(html)
    @

  clearMsgCount: () ->
    @msg_count = 0
    @$('.message_count').hide()

  incMsgCount: (count = 1) ->
    @msg_count += count
    @$('.message_count').html(@msg_count).show()

  getChannel: () ->
    @channel ||= Caramal.Chat.of(@model.get('login'))

  setChannel: (@channel) ->
    @getChannel()
    @channel.open()
    @channel.onMessage (msg) =>
      unless @channel.isActive()
        @channel.message_buffer.push(msg)
        @incMsgCount()
        @active()
    , @

  showChat: () ->
    @unactive()
    $(".global_chat").css('z-index', 9999)
    @setChannel() unless @channel?
    @newChat()
    @chat_view.showWithMsg()

  newChat: () ->
    unless @chat_view 
      @chat_view = new ChatView({ user: @model.get('login'), channel: @channel })
      @bind_chat()

  bind_chat: () ->
    @chat_view.bind("active_avatar", _.bind(@active, @))
    @chat_view.bind("unactive_avatar", _.bind(@unactive, @))

  active: () ->
    $(@el).addClass('active')

  unactive: () ->
    $(@el).removeClass('active')
    @clearMsgCount()


class GroupView extends FriendView
  tagName: 'li'

  events:
    "click" : "showChat"

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Group.of(@model.get('login'))

  newChat: () ->
    unless @chat_view 
      @chat_view = new GroupChatView({ user: @model.get('login'), channel: @channel })
      @bind_chat()

