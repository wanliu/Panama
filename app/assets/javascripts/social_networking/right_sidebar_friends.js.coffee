root = (window || @)

class root.ChatModel extends Backbone.Model
  setAttributes: () ->
    switch @get('type')
      when 1
        @set({
          name: @get('login'),
          title: "好友 #{@get('login')}"
        })
      when 2
        @set({
          name: @get('login'),
          title: "商圈 #{@get('login')}"
        })
      when 3
        name = @get('group')
        number = name.substring(name.indexOf('_')+1, name.length)
        @set({
          name: name, 
          title: "订单 #{number}",
        })

class root.ChatList extends Backbone.Collection
  model: ChatModel

class root.ChatManager extends Backbone.View
  @rows = 1
  @count = 0
  @maxRows = 2

  @getInstance = (options) ->
    ChatManager.instance ||= new ChatManager(options)

  events:
    'keyup input.filter_key' : 'filterList'

  bindItems: () ->
    Caramal.MessageManager.on('channel:new', (channel) =>
      console.log('channel:new ', channel)
      if @is_ready
        @targetView(channel.type).process(channel)
      else
        @unprocessed_channels.push(channel)
    )

  initialize: (options) ->
    _.extend(@, options)
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
    @initFetch()
    @bindItems()
    @bindEvent()
    @$el.slimScroll(height: $(window).height())

  addAll: () ->
    @$("ul").html('')
    @collection.each (model) =>
      @addOne(model)
    @showUnprocessed()

  showUnprocessed: () ->
    setTimeout( () =>
      _.each @unprocessed_channels, (channel) =>
        @targetView(channel.type).process(channel)
      @is_ready = true
    , 200) # fix me: setTimeout should be removed

  addOne: (model) ->
    type = model.get('type') || model.get('follow_type')
    model.set({ type: type }) if type
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

  initFetch: () ->
    @is_ready = false
    @unprocessed_channels = []
    @collection.fetch(url: "/users/channels")

  filterList: (event) ->
    keyword = $(event.target).val().trim()
    @temporarys_view.filterList(keyword)
    @friends_view.filterList(keyword)
    @groups_view.filterList(keyword)

  bindEvent: () ->
    ifvisible.setIdleDuration(60)
    ifvisible.idle () =>
      $(window).trigger('idle')
    ifvisible.wakeup () =>
      $(window).trigger('active')

  setMaxRows: (rows) ->
    ChatManager.maxRows = rows if rows > 0

  setRows: (rows) ->
    rows = ChatManager.maxRows if rows > ChatManager.maxRows
    ChatManager.rows = rows

  newChat: (model) ->
    exist_model = @findExist(model)
    if exist_model && exist_model.chat_view
      return exist_model.chat_view
    else
      switch model.get('type')
        when 1
          new ChatView({model: model})
        when 2
          new GroupChatView({model: model})
        when 3
          new TemporaryChatView({model: model})
        else
          console.error('undefined type...')

  findExist: (model) ->
    _.find @collection.models, (item) =>
      item.get('name') is model.get('name')

  addModel: (model) ->
    # model.setAttributes()
    $("body").append(model.chat_view.el)
    @collection.add(model)
    @addChat(model)
    @addResizable(model)

  addChat: (model) ->
    count = $('.global_chat:visible').length
    $el = $(model.chat_view.el)
    w_width = $(window).width()
    w_height = $(window).height()
    right = $(".right-sidebar").width() + (count-1)*$el.width()

    if right + $el.width() > w_width
      count_x = ~~(w_width/$el.width())
      @setRows(Math.ceil(count/count_x))
      right = $(".right-sidebar").width() + (count-1)%count_x*$el.width()

    top = w_height - ChatManager.rows*$el.height()
    $el.css('right', right + "px")
    $el.css('top', top + "px")

  addResizable: (model) ->
    $el = $(model.chat_view.el)
    $el.resizable().draggable().css('position', 'fixed')
    $el.on('resize', (event, ui) =>
      height = $el.outerHeight() - $el.find(".head").outerHeight() - $el.find(".foot").outerHeight()
      $el.find(".body").css('height', height)
      $el.css('position', 'fixed')
    )


class BaseIconsView extends Backbone.View

  initFetch: () ->
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
    # @initFetch()
    @render()

  addAll: () ->
    @$("ul").html('')
    @collection.each (model) =>
      @addOne(model)

  process: (channel) ->
    exist_model = @findExist(channel)
    if exist_model
      @top(exist_model)
      exist_model.icon_view.setChannel(channel)
    else
      # 临时聊天类型
      model = new ChatModel({ 
        type: 3,
        group: channel.group,
        channel: channel 
      })
      model.setAttributes()
      @parent_view.targetView(3).addModel(model)

  filterList: (keyword) ->
    pattern = new RegExp(keyword)
    _.each @collection.models, (model) ->
      if pattern.test(model.get('login'))
        $(model.icon_view.el).show()
      else
        $(model.icon_view.el).hide()

  findExist: (channel) ->
    _.find @collection.models, (model) =>
      model.get('name') is channel.user

  top: (model) ->
    # @parent_view.active()
    friend_view = model.icon_view
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

  # initFetch: () ->
  #   @collection.fetch(url: "/users/channels")

  addOne: (model) ->
    model.setAttributes()
    friend_view = new FriendIconView({ model: model, parent_view: @ })
    model.icon_view  = friend_view

    @$(".users-list").append(friend_view.render().el)

  removeOne: (model) ->
    if model.icon_view?
      $(model.icon_view.el).remove();

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
    model.setAttributes()
    groupView = new GroupIconView({ model: model, parent_view: @ })
    model.icon_view  = groupView
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

  addModel: (model) ->
    exist_model = @findExist(model)
    if exist_model
      return exist_model
    else
      @collection.add(model)
      return model

  addOne: (model) ->
    temporaryView = new TemporaryIconView({ model: model, parent_view: @ })
    model.icon_view  = temporaryView
    @$(".users-list").append(temporaryView.render().el)

  findExist: (model) ->
    _.find @collection.models, (item) =>
      item.get('name') is model.get('name')


class BaseIconView extends Backbone.View

  tagName: 'li'

  events:
    "click " : "toggleChat"

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
    @model.icon_view = @
    @setChannel() unless @channel?

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

  getChat: () ->
    unless @chat_view
      @chat_view = ChatManager.getInstance().newChat(@model)
      @model.chat_view = @chat_view
      @bind_chat()
    @chat_view

  toggleChat: () ->
    @getChat().toggleDialog()

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

