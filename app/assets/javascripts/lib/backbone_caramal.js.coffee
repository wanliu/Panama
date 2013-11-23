
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


class root.ChatView extends Caramal.BackboneView
  on_class: "online"
  off_class: "offline"
  display_state: true
  className: 'global_chat_panel'

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

  msg_template: _.template('
    <li>
      <div class="title">
        <img src="/default_img/t5050_default_avatar.jpg" class="img-polaroid">
        <span class="login"><%= user %></span>
        <span class="date"><%= new Date().format("hh:mm:ss") %></span>
      </div>
      <div class="message"><%= msg %></div>
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
    $(@el).html(@chat_template(user: @user))
    @state_el = @$(".head>.state")
    $("body").append(@el)
    $(@el).css('top', $(window).height() - $(@el).height() + "px")

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

  initChannel: () ->
    return if @channel?
    @channel ||= Caramal.Chat.of(@user)
    @channel.open()

  bindMessage: () ->
    @channel.onMessage(@receiveMessage, @)

  unbindMessage: () ->
    @channel.removeEventListener('message', @receiveMessage)

  receiveMessage: (msg, context) ->
    data = @msg_template(msg)
    @trigger('active_avatar')
    @$(".msg_content").append(data)

  hideDialog: () ->
    $(@el).hide()
    @channel.deactive()
    @unbindMessage()

  showDialog: () ->
    $(@el).css('z-index', 10000).show()
    @channel.active()
    for msg in @channel.message_buffer
      @receiveMessage(msg)

    @channel.message_buffer.splice(0, @channel.message_buffer.length)
    @bindMessage()

  activeDialog: () ->
    @trigger('unactive_avatar')

  online: () ->
    @state_el.addClass(@on_class).removeClass(@off_class)

  offline: () ->
    @state_el.addClass(@off_class).removeClass(@on_class)

  fastKey: (event) ->
    event = event ? event:window.event
    @sendMeessage() if event.ctrlKey && event.keyCode == 13

  sendMeessage: () ->
    $msg = @$("textarea.content")
    @channel.send($msg.val().trim())
    $msg.val('')
    
