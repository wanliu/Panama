root = (window || @)

class root.ChatListView extends Backbone.View
  events:
    'keyup input.filter_key' : 'filter_list'

  bind_items: () ->
    Caramal.MessageManager.on('channel:new', (channel) =>
      console.log('channel:new ', channel)
      @targetView(channel.type).process(channel)
    )

  initialize: () ->
    @collection = new ChatList()
    @collection.bind('reset', @addAll, @)
    @collection.bind('add', @addOne, @)

    @temporarys_view = new TemporaryIconsView(parent_view: @)
    @friends_view = new FriendIconsView(parent_view: @)
    @groups_view = new GroupIconsView(parent_view: @)

    $(@el).prepend('
      <div class="fixed_head">
        <input class="filter_key" type="text"/>
      </div>')
    @bind_items()
    @$el.slimScroll(height: $(window).height())
    @init_fetch()

  addAll: () ->
    @$("ul").html('')
    @collection.each (model) =>
      @addOne(model)

  addOne: (model) ->
    type = model.get('follow_type')
    @targetView(type).collection.add(model)

  targetView: (type) ->
    switch type
      when 1
        @friends_view
      when 2
        @groups_view
      when 3
        @temporarys_view
      else
        console.error('unprocess type: ', type)

  init_fetch: () ->
    @collection.fetch(url: "/users/channels")

  filter_list: (event) ->
    keyword = $(event.target).val().trim()
    @temporarys_view.filter_list(keyword)
    @friends_view.filter_list(keyword)
    @groups_view.filter_list(keyword)


ChatListView.getInstance = (options) ->
  @instance ||= new ChatListView(options)


class BaseIconsView extends Backbone.View

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
    # @init_fetch()
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
    else
      # just for test
      model = new ChatModel({type: 3, name: 'wl2016', title: '临时 wl2016'})
      @parent_view.temporarys_view.collection.add(model)

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
    # @parent_view.active()
    friend_view = model.view
    friend_view.remove()
    @$("ul").append(friend_view.el)
    friend_view.delegateEvents()


class FriendIconsView extends BaseIconsView
  className: "followings-list"

  template: '
    <ul class="users-list followings">
    </ul>'

  initialize: () ->
    super
    @collection.bind('remove', @removeOne, @)

  render: () ->
    $(@el).html(@template)
    @

  # init_fetch: () ->
  #   @collection.fetch(url: "/users/channels")

  addOne: (model) ->
    model.set({ 
      type: model.get('follow_type'), 
      name: model.get('login'), 
      title: "好友 #{model.get('login')}" 
    })

    friend_view = new FriendIconView({ model: model, parent_view: @ })
    model.view  = friend_view
    @$(".users-list").append(friend_view.render().el)

  removeOne: (model) ->
    if model.view?
      $(model.view.el).remove();

  addFriend: (attributes) ->
    chat = new ChatModel(attributes)
    @collection.add(chat)

  removeFriend: (attributes) ->
    delete attributes['icon']
    @collection.remove(@collection.where(attributes)[0])


class GroupIconsView extends BaseIconsView
  className: "groups-list"

  template: '
    <ul class="users-list groups">
    </ul>'

  initialize: () ->
    super

  render: () ->
    $(@el).html(@template)
    @

  addOne: (model) ->
    model.set({ 
      type: model.get('follow_type'), 
      name: model.get('login'), 
      title: "商圈 #{model.get('login')}" 
    })

    groupView = new GroupIconView({ model: model, parent_view: @ })
    model.view  = groupView
    @$(".users-list").append(groupView.render().el)


class TemporaryIconsView extends BaseIconsView
  className: 'temporarys-list'

  template: '
    <ul class="users-list temporarys">
    </ul>'

  initialize: () ->
    super

  render: () ->
    $(@el).html(@template)
    @

  addOne: (model) ->
    model.set({ 
      type: 3, 
      name: model.get('name'), 
      title: "临时 #{model.get('name')}" 
    })
    temporaryView = new TemporaryIconView({ model: model, parent_view: @ })
    model.view  = temporaryView
    @$(".users-list").append(temporaryView.render().el)


class BaseIconView extends Backbone.View

  tagName: 'li'

  events:
    "click" : "showChat"

  template: Handlebars.compile("""
    <a href="#" data-toggle="tooltip" data-placement="left" data-container="body" title="{{title}}">
      <span class="badge badge-important message_count"></span>
      {{#if icon}}
        <img src='{{icon}}' alt='{{title}}' />
      {{else}}
        <img src="/default_img/t5050_default_avatar.jpg" alt={{title}} class="" />
      {{/if}}
    </a>""")

  initialize: () ->
    @clearMsgCount()
    @model.view = @

  render: () ->
    html = @template(@model.attributes)
    $(@el).html(html)
    @

  clearMsgCount: () ->
    @msg_count = 0
    @$('.message_count').hide()

  incMsgCount: () ->
    @msg_count += 1
    @$('.message_count').html(@msg_count).show()

  setChannel: (@channel) ->
    @getChannel()
    @model.set({ channel: @channel })
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
      @chat_view = ChatService.getInstance().newChat(@model)
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


class FriendIconView extends BaseIconView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Chat.of(@model.get('name'))


class GroupIconView extends BaseIconView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Group.of(@model.get('name'))


class TemporaryIconView extends BaseIconView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Group.of(@model.get('name'))

