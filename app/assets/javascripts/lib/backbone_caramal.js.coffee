#= require lib/handlebars-v1.1.2

root = window || @

class Caramal.BackboneView extends Backbone.View

  default_driver: Caramal.Chat

  PROXY_METHODS: [
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


class root.ChatLayout
  @rows = 1
  @count = 0
  @maxRows = 2

  @getInstance = (options) ->
    ChatLayout.instance ||= new ChatLayout(options)

  constructor: (options) ->
    _.extend(@, options)

  setMaxRows: (rows) ->
    ChatLayout.maxRows = rows if rows > 0

  setRows: (rows) ->
    rows = ChatLayout.maxRows if rows > ChatLayout.maxRows
    ChatLayout.rows = rows

  setPosition: ($el) ->
    ChatLayout.count += 1
    w_width = $(window).width()
    w_height = $(window).height()
    right = $(".right-sidebar").width() + (ChatLayout.count-1)*$el.width()

    if right + $el.width() > w_width
      count_x = ~~(w_width/$el.width())
      @setRows(Math.ceil(ChatLayout.count/count_x))
      right = $(".right-sidebar").width() + (ChatLayout.count-1)%count_x*$el.width()

    top = w_height - ChatLayout.rows*$el.height()
    $el.css('right', right + "px")
    $el.css('top', top + "px")

Handlebars.registerHelper 'calender', (time) ->
  date = if time?
           new Date(parseInt(time))
         else
           new Date()

  date.format('yyyy-MM-dd hh:mm:ss')



class root.ChatView extends Caramal.BackboneView
  msgLoaded: false
  on_class: "online"
  off_class: "offline"
  className: 'global_chat_panel'

  history_tip: _.template('<li class="text-center">-----<%= text %>-----</li>')

  chat_template:  _.template('
    <div class="head">
      <span class="state online"></span>
      <span class="name"><%= user %></span>
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

  events:
    'mouseover '            : 'activeDialog'
    'click .close_label'    : 'hideDialog'
    'click .send_button'    : 'sendMeessage'
    "keyup textarea.content": "fastKey"

  initialize: (options) ->
    super
    _.extend(@, options)

    @initChannel()
    @initDialog()
    @bindDialog()

  initDialog: () ->
    @display = false
    $(@el).html(@chat_template(user: @user))
    @state_el = @$(".head>.state")
    $("body").append(@el)
    ChatLayout.getInstance().setPosition($(@el))

  bindDialog: () ->
    $(@el).resizable().draggable().css('position', 'fixed')
    $(@el).on('resize', (event, ui) =>
      height = $(@el).outerHeight() - @$(".head").outerHeight() - @$(".foot").outerHeight()
      @$(".body").css('height', height)
      $(@el).css('position', 'fixed')
    )
    window.clients.on('disconnect', (error) =>
      @offline()
    )


  fetchHistoryMsg: (force = false) ->
    return if !force && @msgLoaded
    @channel.history({start: 1}, (chat, err, messages) =>
      $html = @parseMessages(messages)
      text = if $html is '' then '没有聊天记录' else '以上是聊天记录'
      $html += @history_tip({text: text})
      @$('.msg_content').prepend($html)
    )
    @msgLoaded = true

  parseMessages: (messages) ->
    $html = ''
    messages = [messages] unless $.isArray(messages)
    _.each messages, (message) =>
      $html += @msg_template(message)
    $html

  receiveMessage: (data) ->
    @$('.msg_content').append(@parseMessages(data))
    @trigger('active_avatar') if @user is data.user
    @$('.body').scrollTop(@$('.body')[0].scrollHeight)

  hideDialog: () ->
    $(@el).hide()
    @channel.deactive()
    @unbindMessage() if @display
    @display = false

  showDialog: () ->
    $(@el).css('z-index', 10000).show()
    @channel.active()
    _.each @channel.message_buffer, (msg) => @receiveMessage(msg)
    @channel.message_buffer.splice(0, @channel.message_buffer.length)
    @bindMessage() unless @display
    @display = true

  showWithMsg: () ->
    @fetchHistoryMsg()
    @showDialog()

  initChannel: () ->
    return if @channel?
    @channel ||= Caramal.Chat.of(@user)
    @channel.open()

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
    @sendMeessage() if event.ctrlKey && event.keyCode == 13

  sendMeessage: () ->
    $msg = @$("textarea.content")
    @channel.send($msg.val().trim())
    $msg.val('')

