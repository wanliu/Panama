#= require lib/handlebars-v1.1.2

root = window || @

class Caramal.BackboneView extends Backbone.View

  default_driver: Caramal.Chat

  PROXY_METHODS: [
    'onCommand',
    'onMessage',
    'onEvent',
    'open',
    'join',
    'send'
  ]

  initialize: (user) ->
    for name in @PROXY_METHODS
      if _.isFunction(@[name])
        throw new Error('always have this named method of ' + name);
      else
        @[name] = (args...) =>
          unless @channel?
            @channel = Caramal.MessageManager.nameOfChannel(user) or
              @default_driver.create(user)
          @channel[name].apply(@channel, args)


class ChatService
  @rows = 1
  @count = 0
  @maxRows = 2

  @getInstance = (options) ->
    ChatService.instance ||= new ChatService(options)

  constructor: (options) ->
    _.extend(@, options)
    @bindEvent()

  bindEvent: () ->
    ifvisible.idle () =>
      $(window).trigger('idle')
    ifvisible.wakeup () =>
      $(window).trigger('active')

  setMaxRows: (rows) ->
    ChatService.maxRows = rows if rows > 0

  setRows: (rows) ->
    rows = ChatService.maxRows if rows > ChatService.maxRows
    ChatService.rows = rows

  setPosition: ($el) ->
    ChatService.count += 1
    w_width = $(window).width()
    w_height = $(window).height()
    right = $(".right-sidebar").width() + (ChatService.count-1)*$el.width()

    if right + $el.width() > w_width
      count_x = ~~(w_width/$el.width())
      @setRows(Math.ceil(ChatService.count/count_x))
      right = $(".right-sidebar").width() + (ChatService.count-1)%count_x*$el.width()

    top = w_height - ChatService.rows*$el.height()
    $el.css('right', right + "px")
    $el.css('top', top + "px")

Handlebars.registerHelper 'calender', (time) ->
  date = if time?
           new Date(parseInt(time))
         else
           new Date()

  date.format('yyyy-MM-dd hh:mm:ss')



class BaseChatView extends Caramal.BackboneView
  on_class: "online"
  off_class: "offline"
  className: 'global_chat'

  EVENT_TYPE: {
    'joined'     : 1,
    'leaved'     : 2,
    'inputing'   : 3,
    'onlineState': 4
  }

  events:
    'mouseover '            : 'activeDialog'
    'click .close_label'    : 'hideDialog'
    'click .send_button'    : 'sendMeessage'
    "keyup textarea.content": "fastKey"

  history_tip: _.template('<li class="text-center">-----<%= text %>-----</li>')

  chat_template:  _.template('
    <div class="head">
      <span class="state online"></span>
      <span class="name"><%= user %></span>
      <span class="input_state"></span>
      <a class="close_label" href="javascript:void(0)"></a>
    </div>
    <div class="body">
      <ul class="msg_content">
      </ul>
    </div>
    <div class="foot">
      <div class="send_content">
        <textarea class="content"></textarea>
      </div>
      <div class="foot_nav">
        <button class="send_button">发送</button>
      </div>
    </div>')

  msg_template: Handlebars.compile('
    <li>
      <div class="title">
        <img src="/default_img/t5050_default_avatar.jpg" class="img-polaroid">
        <span class="login">{{ user }}</span>
        <span class="date">{{calender time}}</span>
      </div>
      <div class="message">{{ msg }}</div>
    </li>')

  fetchHistory: () ->
    @msgLoaded ||= false
    return if @msgLoaded
    @channel.history({start: 1}, (chat, err, messages) =>
      $html = @parseMessages(messages)
      text = if $html is '' then '没有聊天记录' else '以上是聊天记录'
      $html += @history_tip({text: text})
      @$('.msg_content').prepend($html)
    )
    @msgLoaded = true

  resetHistory: () ->
    @msgLoaded = false
    @$('.msg_content').html('')
    @fetchHistory()

  initialize: (options) ->
    super
    _.extend(@, options)

    @initChannel()
    @initDialog()
    @bindDialog()
    @bindEvent()

  initChannel: () ->
    @getChannel()
    @channel.open()
    @channel.record()

  initDialog: () ->
    @display = false
    $(@el).html(@chat_template(user: @user))
    @state_el = @$(".head>.state")
    $("body").append(@el)
    ChatService.getInstance().setPosition($(@el))

  bindDialog: () ->
    $(@el).resizable().draggable().css('position', 'fixed')
    $(@el).on('resize', (event, ui) =>
      height = $(@el).outerHeight() - @$(".head").outerHeight() - @$(".foot").outerHeight()
      @$(".body").css('height', height)
      $(@el).css('position', 'fixed')
    )

  bindEvent: () ->
    @stateService()
    window.clients.on 'connect', (error) => @channel.online_state('online')
    window.clients.on 'disconnect', (error) => @channel.online_state('away')
    @channel.onEvent (data) =>
      return unless data.type
      switch parseInt(data.type)
        when @EVENT_TYPE['inputing']
          @showInputing()
        when @EVENT_TYPE['onlineState']
          @onlineState(data.state)
        when @EVENT_TYPE['joined']
          @online()
        when @EVENT_TYPE['leaved']
          @offline()
        else
          console.log('未处理的事件')

  stateService: (time = 60) ->
    ifvisible.setIdleDuration(time)
    $(window).bind('idle', () =>
      # 通知对方自己已经离开
      @channel.online_state('away')
    )
    $(window).bind('active', () =>
      # 通知对方自己已经上线
      @channel.online_state('online')
    )

  onlineState: (state) ->
    switch state
      when 'online'
        @online()
      when 'away'
        @offline()
      else
        console.log('未处理的在线状态')

  showInputing: (time = 5000) ->
    @$('.input_state').html('正在输入...')
    setTimeout(() =>
      @$('.input_state').html('')
    , time)

  sendInputing: (time = 30000) ->
    @activeTime ||= new Date().getTime()
    if new Date().getTime() - @activeTime > time
      @channel.being_input()
      @activeTime = new Date().getTime()

  parseMessages: (messages) ->
    $html = ''
    messages = [messages] unless $.isArray(messages)
    _.each messages, (message) =>
      $html += @msg_template(message)
    $html

  receiveMessage: (data) ->
    @$('.msg_content').append(@parseMessages(data))
    @trigger('active_avatar') if @user is data.user
    @scrollDialog()

  hideDialog: () ->
    $(@el).hide()
    @channel.deactive()
    @unbindMessage() if @display
    @display = false

  showDialog: () ->
    $(@el).css('z-index', 10000).show()
    @channel.active()
    @showUnread()
    @bindMessage() unless @display
    @display = true

  scrollDialog: () ->
    @$('.body').scrollTop(@$('.body')[0].scrollHeight)

  showUnread: () ->
    _.each @channel.message_buffer, (msg) =>
      @receiveMessage(msg)
    @channel.message_buffer.splice(0, @channel.message_buffer.length)

  showWithMsg: () ->
    @resetHistory()
    @showDialog()

  bindMessage: () ->
    @channel.onMessage(@receiveMessage, @)

  unbindMessage: () ->
    @channel.removeEventListener('message', @receiveMessage)

  activeDialog: () ->
    @trigger('unactive_avatar')

  online: () ->
    @state_el.addClass(@on_class).removeClass(@off_class)

  offline: () ->
    @state_el.addClass(@off_class).removeClass(@on_class)

  fastKey: (event) ->
    @sendInputing()
    @sendMeessage() if event.ctrlKey && event.keyCode == 13

  sendMeessage: () ->
    $msg = @$("textarea.content")
    msg = $msg.val().trim()
    return if msg is ''
    @channel.send(msg)
    $msg.val('')


class root.ChatView extends BaseChatView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Chat.of(@user)
    @channel.open()

  fetchHistoryMsg: () ->
    @msgLoaded ||= false
    return if @msgLoaded
    @channel.history({start: 1}, (chat, err, messages) =>
      $html = @parseMessages(messages)
      text = if $html is '' then '没有聊天记录' else '以上是聊天记录'
      $html += @history_tip({text: text})
      @$('.msg_content').prepend($html)
    )
    @msgLoaded = true


class root.GroupChatView extends BaseChatView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Group.of(@user)

  fastKey: (event) ->
    @sendMeessage() if event.ctrlKey && event.keyCode == 13


