root = (window || @)

class root.ChatContainerView extends RealTimeContainerView
  events:
    'keyup input.filter_key' : 'filter_list'

  initialize: () ->
    super
    @stranger_view  = new StrangersView(parent_view: @)
    @friends_view = new FriendsView(parent_view: @)
    @groups_view = new GroupsView(parent_view: @)
    $(@el).prepend('
      <div class="fixed_head">
        <input class="filter_key" type="text"/>
      </div>')
    @bind_items()

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


class BaseFriendsView extends Backbone.View

  init_fetch: () ->
    console.log('unimplemented...')

  addOne: (model) ->
    console.log('unimplemented...')

  initialize: () ->
    @parent_view  = @options.parent_view
    @$parent_view = $(@options.parent_view.el)
    @$parent_view.append(@el)
    @collection = new ChatList()
    @collection.bind('reset', @addAll, @)
    @collection.bind('add', @addOne, @)
    @init_fetch()
    @render()

  addAll: () ->
    @$("ul").html('')
    @collection.each (model) =>
      @addOne(model)

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
    _.find @collection.models, (model) =>
      model.get('login') is channel.user

  top: (model) ->
    @parent_view.active()
    friend_view = model.view
    friend_view.remove()
    @$("ul").append(friend_view.el)
    friend_view.delegateEvents()


class FriendsView extends BaseFriendsView
  className: "followings-list"

  template:
    '<h5 class="tab-header">
      <i class="icon-group"></i>
       我关注的[<span class="num">0</span>]
    </h5>
    <ul class="users-list followings">
    </ul>'

  initialize: () ->
    super

  render: () ->
    $(@el).html(@template)
    @

  init_fetch: () ->
    @collection.fetch(url: "/users/channels")

  addOne: (model) ->
    friend_view = new FriendView({ model: model, parent_view: @ })
    model.view  = friend_view
    @$(".users-list").append(friend_view.render().el)


class GroupsView extends BaseFriendsView
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
      @collection.add(new ChatModel({name: 'random_' + i }))

  render: () ->
    $(@el).html(@template)
    @

  addOne: (model) ->
    groupView = new GroupView({ model: model, parent_view: @ })
    model.view  = groupView
    @$(".users-list").append(groupView.render().el)


class StrangersView extends BaseFriendsView
  className: "strangers-list"

  template:
    '<h5 class="tab-header">
      <i class="icon-group"></i>
       陌生人[<span class="num">0</span>]
    </h5>
    <ul class="users-list strangers">
    </ul>'

  initialize: () ->
    super

  render: () ->
    $(@el).html(@template)
    @

  addOne: (model) ->
    if @collection.length is 1 and @parent_view.$('.strangers').length is 0
      @$parent_view.find(".fixed_head").after(@el)
    stanger_view = new StrangerView({ model: model, parent_view: @ })
    model.view  = stanger_view
    @$(".users-list").append(stanger_view.render().el)

  process: (channel) ->
    @channel = channel
    model = new ChatModel()
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
    _.find @collection.models, (item) =>
      item.id is model.id


class BaseFriendView extends Backbone.View
  tagName: 'li'

  events:
    "click" : "showChat"

  template: _.template('
    <a href="#" data-toggle="tooltip" title="<%= model.get("login")||model.get("name") %>">
      <span class="badge badge-important message_count"></span>
      <img src="/default_img/t5050_default_avatar.jpg" class="img-circle" />
    </a>')

  initialize: () ->
    @clearMsgCount()

  render: () ->
    html = @template({model: @model})
    $(@el).html(html)
    @

  clearMsgCount: () ->
    @msg_count = 0
    @$('.message_count').hide()

  incMsgCount: (count = 1) ->
    @msg_count += count
    @$('.message_count').html(@msg_count).show()

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
    unless @chat_view
      @chat_view = @newChat()
      @bind_chat()
    @chat_view.showWithMsg()

  bind_chat: () ->
    @chat_view.bind("active_avatar", _.bind(@active, @))
    @chat_view.bind("unactive_avatar", _.bind(@unactive, @))

  active: () ->
    $(@el).addClass('active')

  unactive: () ->
    $(@el).removeClass('active')
    @clearMsgCount()


class StrangerView extends BaseFriendView
  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Chat.of(@model.get('login'))

  newChat: () ->
    model = new ChatModel({
      type: 1,
      channel: @channel, 
      name: @model.get('login'), 
      title: "陌生人 #{@model.get('login')}" 
    })
    ChatService.getInstance().newChat(model)


class FriendView extends BaseFriendView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Chat.of(@model.get('login'))

  newChat: () ->
    model = new ChatModel({
      type: 1,
      channel: @channel, 
      name: @model.get('login'), 
      title: "好友 #{@model.get('login')}" 
    })
    ChatService.getInstance().newChat(model)


class GroupView extends BaseFriendView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Group.of(@model.get('name'))

  newChat: () ->
    model = new ChatModel({
      type: 2,
      channel: @channel, 
      name: @model.get('name'), 
      title: "群组 #{@model.get('name')}"
    })
    ChatService.getInstance().newChat(model)

