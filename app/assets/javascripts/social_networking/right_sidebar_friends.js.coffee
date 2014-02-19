root = (window || @)

class root.ChatModel extends Backbone.Model
  getOrderUrl: () ->
    pages = [ '/transactions', '/pending', '/direct_transactions', '/order_refunds' ]
    url = _.find pages, (page) => location.href.indexOf(page) != -1

  getPrefixTitle: (group) ->
    prefix = group.substring(0, group.indexOf('_'))
    switch prefix
      when 'OrderTransaction'
        @set({ attach_el: '[data-group="'+@get('group')+'"] .message_wrap' })
        '担保交易'
      when 'DirectTransaction'
        @set({ attach_el: '[data-group="'+@get('group')+'"] .message_wrap' })
        '直接交易'
      when 'Activity'
        '活动'
      else
        console.error('未处理的类型')

  setAttributes: () ->
    type = @get('type') || @get('follow_type')
    @set({ type: type }) if type
    switch @get('type')
      when 1
        title = @get('title') || "好友 #{@get('login')}"
        @set({
          name: @get('login'),
          title: title
        })
      when 2
        name = @get('login') || @get('group')
        title = @get('title') || "商圈 #{name}"
        @set({
          name: name,
          group: name,
          title: title
        })
      when 3
        name = @get('name') || @get('group')
        group = @get('group')
        number = group.substring(group.indexOf('_')+1, group.length)
        title = @get('title') || "#{@getPrefixTitle(group)} #{number}"
        @set({
          number: number,
          name: name,
          group: group,
          title: title
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
    'keyup input.filter_key' : 'filterChat'

  bindItems: () ->
    Caramal.MessageManager.on('channel:new', (channel) =>
      # console.log('channel:new ', channel)
      return unless channel.type is 3
      if @is_ready
        @targetView(channel.type).process(channel)
      else
        @unprocessed_channels.push(channel)
    )

  initialize: (options) ->
    _.extend(@, options)
    @collection = new ChatList()
    @collection.bind('reset', @addAll, @)
    @collection.bind('add', @addChatIcon, @)
    @collection.bind('remove', @removeChatIcon, @)

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
      @addChatIcon(model)
    @showUnprocessed()

  showUnprocessed: () ->
    setTimeout( () =>
      _.each @unprocessed_channels, (channel) =>
        @targetView(channel.type).process(channel)
      @is_ready = true
    , 300) # fix me: setTimeout should be removed

  addChatIcon: (model) ->
    model.setAttributes()
    exist_model = @findExist(model)
    if model.get('type') is 3 && exist_model
      return exist_model
    else
      targetView = @targetView(model.get('type'))
      targetView.collection.add(model)
      model = targetView.collection.where(model.attributes)[0]

  removeChatIcon: (model) ->
    model.setAttributes()
    targetView = @targetView(model.get('type'))
    exist_model = targetView.collection.where(model.attributes)[0]
    targetView.collection.remove(exist_model)

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

  filterChat: (event) ->
    keyword = $(event.target).val().trim()
    views = [ @friends_view, @groups_view, @temporarys_view ]
    _.each views, (view) => view.filterList(keyword)

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
          new FriendChatView({model: model})
        when 2
          new GroupChatView({model: model})
        when 3
          if model.getOrderUrl()
            new OrderChatView({model: model})
          else
            new TemporaryChatView({model: model})
        else
          console.error('undefined type...')

  findExist: (item) ->
    type = item.type || item.get('type')
    _.find @collection.models, (model) =>
      if type is model.get('type')
        switch type
          when 1
            model.get('name') is (item.user || item.get('name'))
          when 2
            model.get('group') is (item.group || item.get('group'))
          when 3
            model.get('group') is  (item.group || item.get('group'))

  addModel: (model) ->
    @collection.add(model)
    @addChat(model)

  addChat: (model) ->
    count = $('.global_chat').length
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


class BaseIconsView extends Backbone.View

  initFetch: () ->
    console.log('unimplemented...')

  addOne: (model) ->
    console.log('unimplemented...')

  removeOne: (model) ->
    $(model.icon_view.el).remove() if model.icon_view?
    $(model.chat_view.el).remove() if model.chat_view?

  initialize: () ->
    @parent_view  = @options.parent_view
    @$parent_view = $(@options.parent_view.el)
    @$parent_view.append(@el)
    @collection = new ChatList()
    @collection.bind('reset', @addAll, @)
    @collection.bind('add', @addOne, @)
    @collection.bind('remove', @removeOne, @)
    @render()

  addAll: () ->
    @$("ul").html('')
    @collection.each (model) =>
      @addOne(model)

  process: (channel) ->
    exist_model = @parent_view.findExist(channel)
    if exist_model
      @top(exist_model)
      return unless channel.type is 3
      exist_model.icon_view.setChannel(channel)
    else
      model = new ChatModel({ 
        type: channel.type,
        name: channel.name,
        group: channel.group,
        channel: channel 
      })
      @parent_view.targetView(channel.type).addModel(model)

  filterEmpty: () ->
    _.each @collection.models, (model) ->
      $(model.icon_view.el).show()

  filterList: (keyword) ->
    pattern = new RegExp(keyword)
    if _.isEmpty(keyword)
      @filterEmpty()
    else
      _.each @collection.models, (model) ->
        # be sure title is exists
        if pattern.test(model.get('title'))
          $(model.icon_view.el).show()
        else
          $(model.icon_view.el).hide()

  addModel: (model) ->
    exist_model = @parent_view.findExist(model)
    if exist_model
      return exist_model
    else
      model.setAttributes()
      return pnotify(type: 'error', text: '请求聊天失败，token为空') unless model.get('name')
      @parent_view.collection.add(model)
      @collection.add(model)
      return model

  top: (model) ->
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

  render: () ->
    $(@el).html(@template)
    @

  addOne: (model) ->
    friend_view = new FriendIconView({ model: model, parent_view: @ })
    model.icon_view  = friend_view
    @$(".users-list").append(friend_view.render().el)


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

  addOne: (model) ->
    temporaryView = new TemporaryIconView({ model: model, parent_view: @ })
    model.icon_view  = temporaryView
    @$(".users-list").append(temporaryView.render().el)

  filterEmpty: () ->
    _.each @collection.models, (model) ->
      # 默认显示激活状态的临时聊天头像
      if model.icon_view.channel.isActive()
        $(model.icon_view.el).show()
      else
        $(model.icon_view.el).hide()


class BaseIconView extends Backbone.View

  tagName: 'li'

  events:
    'click '   : "showChat"
    'mouseout ': 'hideTooltip'

  template: Handlebars.compile("""
    <a href="javascript:void(0)" data-toggle="tooltip" data-placement="left" data-container="body" title="{{title}}">
      <span class="badge badge-important message_count">0</span>
      {{#if icon}}
        <img src='{{icon}}' alt='{{title}}' />
      {{else}}
        <img src="/default_img/t5050_default_avatar.jpg" alt={{title}} class="" />
      {{/if}}
    </a>""")

  initialize: () ->
    @model.icon_view = @
    @setChannel() unless @channel?

  render: () ->
    html = @template(@model.attributes)
    $(@el).html(html)
    @clearMsgCount()
    @

  hideTooltip: (event) ->
    @$('[data-toggle="tooltip"]').tooltip('hide')
    event.stopPropagation()

  clearMsgCount: () ->
    @msg_count = 0
    @$('.message_count').hide()

  incMsgCount: () ->
    @msg_count += 1
    @$('.message_count').html(@msg_count).show()

  setChannel: (@channel) ->
    @getChannel()
    @model.set({ channel: @channel })
    @channel.onMessage (msg) =>
      $(@el).show()
      # if @channel.isActive()
      if @chat_view && $(@chat_view.el).is(':visible')
        @chat_view.receiveMessage(msg)
      else
        @channel.message_buffer.push(msg)
        @incMsgCount()
        @active()
    , @

    @channel.on 'unreadMsgsSeted', (unreadMsgCount) =>
      @msg_count += unreadMsgCount
      @$('.message_count').html(@msg_count).show() if @msg_count > 0

  getChat: () ->
    unless @chat_view
      @chat_view = ChatManager.getInstance().newChat(@model)
      @model.chat_view = @chat_view
      @bind_chat()
    @chat_view

  showChat: () ->
    @toggleChat()

  toggleChat: () ->
    @getChat().toggleDialog()

  bind_chat: () ->
    @model.bind("active_avatar", _.bind(@active, @))
    @model.bind("unactive_avatar", _.bind(@unactive, @))

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
    @channel.open()


class GroupIconView extends BaseIconView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Group.of(@model.get('name'))
    @channel.open()


class TemporaryIconView extends BaseIconView

  initialize: () ->
    super
    $(@el).hide()

  getChannel: () ->
    @channel ||= Caramal.Temporary.of(@model.get('group'), { name: @model.get('name') })
    if @channel.room
      clients.socket.emit('join', {room: @channel.room})
    else
      clients.socket.emit('open', { group: @channel.group, type: 3 }, (error, msg) =>
        pnotify(type: 'error', text: '请求聊天房间号失败') if _.isEmpty(msg)
        @channel.room = msg
        clients.socket.emit('join', {room: @channel.room})
      )

  showChat: () ->
    url = @model.getOrderUrl()
    if url
      @gotoOrder(url)
    else
      @toggleChat()

  gotoOrder: (url) ->
    number = @model.get('number')
    flag = number.indexOf('D') is -1    # true 担保交易，false 直接交易
    current_shop = clients.current_shop # true admin页面，false people页面

    if current_shop
      if flag
        # /shops/xxx/admins/pending#open/yyy/order
        transactions = "pending"
      else
        # /shops/xxx/admins/direct_transactions#open/yyy/direct
        transactions = "direct_transactions"
      goto = "/shops/#{current_shop}/admins/#{transactions}"
    else
      if flag
        # /people/xxx/transactions#open/yyy/order
        transactions = "transactions"
      else
        # /people/xxx/direct_transactions#open/yyy/direct
        transactions = "direct_transactions"
      goto = "/people/#{clients.current_user}/#{transactions}"

    if flag
      type = 'order'
    else
      type = 'direct'
    goto += "#open/#{~~@model.get('number').replace(/\D/, '')}/#{type}"
    location.href = goto unless location.href is goto

