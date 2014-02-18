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


class ImageUpload extends Backbone.View
  input_name: "attachable"
  action: "/attachments/upload"
  messages: {
    sizeError: "{file}图片，超过{sizeLimit}了！",
    typeError: "请选择正确的{file}图片，只支持{extensions}图片"
  }

  template: '
    <div class="qq-uploader">
      <pre class="qq-upload-drop-area">
        <span>{dragText}</span>
      </pre>
      <div class="qq-upload-button btn" style="width: auto;">
        <i class="icon-picture icon-white"></i>
        {uploadButtonText}
      </div>
      <ul class="qq-upload-list hide" style="margin-top: 10px; text-align: center;">
      </ul>
    </div>'

  initialize: (options) ->
    _.extend(@, options)
    @newFileUploader()

  onProgress: (id, filename, loaded, total) =>
    @$("div.qq-upload-button").hide()

  onSubmit: (id, filename) =>
    @fileupload.setParams({ authenticity_token: window.clients.form_token })

  onComplete: (id, filename, data) =>
    if data.success
      @$("div.qq-upload-button").show()
      @parent_view.sendImg(data.attachment.photos)

  newFileUploader: () ->
    @fileupload = new qq.FileUploader({
      element: @$(".upload-panel")[0],
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      sizeLimit: 1048576,
      minSizeLimit: 0,
      debug : true,
      multiple: false,
      action: @action,
      inputName: @input_name,
      template: @template,
      failUploadText: '',
      uploadButtonText: '',
      cancelButtonText: '取消',
      dragText: '拖放到这里发送图片',
      onSubmit: @onSubmit,
      messages: @messages,
      onProgress: @onProgress,
      onComplete: @onComplete
    })


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
    'mouseover '                : 'activeDialog'
    'click .close_label'        : 'hideDialog'
    'click .send_button'        : 'sendMessage'
    'click .emojify-chooser img': 'chooseEmojify'
    'keyup textarea.content'    : 'fastKey'
    # 'scroll div.body'           : 'more_unread_histroy'

  # history_tip: _.template('<li class="text-center">-----<%= text %>-----</li>')

  chat_template:  _.template('
    <div class="head">
      <span class="state online"></span>
      <span class="name"><%= model.get("title") %></span>
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
        <span class="face-panel">
          <a href="javascript:void(0)" class="btn choose-face" data-toggle="popover" data-trigger="click" data-placement="top" data-html="true" data-original-title="">
            <i class="icon-glass"></i>
          </a>
        </span>
        <span class="upload-panel">
          <i class="icon-picture upload-image"></i>
        </span>
        <button class="btn btn-primary send_button">发送</button>
      </div>
    </div>')

  sys_msg_template: _.template("
    <li>
      <div class='alert alert-info'>
        <i class='icon-info-sign'></i>系统消息：<%= message.msg %>
      </div>
    </li>")

  receive_template: Handlebars.compile('
    <li clas="row-receive">
      <div class="pull-left">
        <div class="icon">
          <img src="/default_img/t5050_default_avatar.jpg">
        </div>
      </div>
      <div class="message-body">
        <div class="pull-left">
          <a href="#" class="login">{{ user }}</a>
          {{calender time}}
        </div>
        <div class="message">
          {{ msg }}
          {{#each attachments}}
            <a class="image-zoom" target="_blank" href="{{default}}">
              <img src="{{header}}" alt="图片">
            </a>
          {{/each}}
        </div>
      </div>
    </li>')

  fetchHistory: () ->
    # @msgLoaded ||= false
    # return if @msgLoaded
    # start = @channel.message_buffer.length + 1
    # setTimeout( () =>
    #   @channel.history({start: start}, (chat, err, messages) =>
    #     @msgLoaded = true
    #     $html = @parseMessages(messages)
    #     text = if $html is '' then '没有聊天记录' else '以上是聊天记录'
    #     $html += @history_tip({text: text})
    #     @msgContent().prepend($html)
    #     @$('.message .image-zoom').fancybox()
    #     @scrollDialog()
    #   )
    # , 300)

  resetHistory: () ->
    @msgLoaded = false
    @msgContent().html('')
    # @fetchHistory()

  initialize: (options) ->
    super
    @name = @model.get('name')
    @title = @name unless @title
    @channel = @model.get('channel')
    return pnotify(type: 'error', text: '请求聊天失败，name为空') unless @name
    @bindEvent()
    @initChannel()
    @initDialog()

  getChannel: () ->
    console.error('unimplemented...')
    @bindSysMsg()

  initChannel: () ->
    @getChannel()
    @channel.open( () =>
      @channel.record()
      @channel_ready = true
    )

  initDialog: () ->
    # @bindMessage()
    $(@el).html(@chat_template({model: @model}))
    @$('div.body').scroll($.proxy(@more_unread_histroy, @))
    @state_el = @$(".head>.state")
    @model.chat_view = @
    @display = false
    $('body').append(@el)
    @addResizable()

    ChatManager.getInstance().addModel(@model)
    new ImageUpload({ el: @el, parent_view: @ })
    @$('.choose-face').popover({
      content: () => EmojifyChooser.getInstance().el
    })
    $(@el).hide()

  addResizable: () ->
    $el = $(@el)
    $el.resizable()
       .draggable(handle: @$('.head'))
       .css('position', 'fixed')
    $el.on('resize', (event, ui) =>
      height = $el.outerHeight() - $el.find(".head").outerHeight() - $el.find(".foot").outerHeight()
      $el.find(".body").css('height', height)
      $el.css('position', 'fixed')
    )

  bindEvent: () ->
    @stateService()
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

  stateService: () ->
    console.log('unimplemented...')

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

  sendInputing: (time) ->

  chooseEmojify: (event) ->
    @$('.choose-face').popover('hide')
    @sendContent().insertAtCursor(":#{$(event.target).data('name')}:")

  parseOne: (message) ->
    if message.user is clients.current_user
      html = @receive_template(message)
    else
      html = @receive_template(message)

    html.replace(/:([a-z]|_)+:/g, (word) =>
      '<img src="/assets/emojis/' + word.replace(/:/g, '') + '.png" class="emoji"/>'
    )

  parseMessages: (messages) ->
    html = ''
    messages = [messages] unless $.isArray(messages)
    _.each messages, (message) =>
      html += @parseOne(message)
    html

  parseSysMsg: (message) ->
    @sys_msg_template({ message: message })

  sendContent: () ->
    @$('.content')

  msgContent: () ->
    @$('.msg_content')

  receiveMessage: (data) ->
    if @display
      @msgContent().append(@parseMessages(data))
      @model.trigger('active_avatar') if @name is data.user
      @$('.message .image-zoom').fancybox()
      @scrollDialog()

  receiveSysMsg: (data) ->
    if @display
      @msgContent().append(@parseSysMsg(data))
      @model.trigger('active_avatar') if @name is data.user
      @$('.message .image-zoom').fancybox()
      @scrollDialog()

  receiveHisMessage: (options) ->
    # if @display
    msgs = options.msgs
    origin_height = @$('.body')[0].scrollHeight
    @msgContent().prepend(@parseMessages(msgs))
    setTimeout () =>
      height = @$('.body')[0].scrollHeight
      diff = height - origin_height
      @$('.body').scrollTop(diff)

    if !options.theEnd
      @showMoreFlag()
    else
      @removeMoreFlag()
    # @model.trigger('active_avatar') if @name is msgs.user
    if @display
      @$('.message .image-zoom').fancybox()
      # @scrollDialog()

  more_unread_histroy: (event) ->
    target = event.target || event.srcElement
    if $(target).scrollTop() < 5
      setTimeout(() =>
        @channel.fetchUnread()
      , 800)

  showMoreFlag: () ->
    moreFlag = @msgContent().find('.showMoreFlag')
    moreFlag.remove()
    @msgContent().prepend("<li class='row-receive showMoreFlag' style='text-align: center; color: #478ebb'>\
      <i class='icon-time'></i>查看更多信息</li>")

  removeMoreFlag: () ->
    moreFlag = @msgContent().find('.showMoreFlag')
    moreFlag.remove()

  toggleDialog: () ->
    if @display
      @hideDialog()
    else
      @showWithMsg()

  hideDialog: () ->
    $(@el).hide()
    @display = false
    @channel.deactive()
    # @unbindMessage()


  showDialog: () ->
    $(@el).show()
    @display = true
    @channel.active()
    @showUnread()
    # @bindMessage()
    @scrollDialog()

  scrollDialog: () ->
    @$('.body').scrollTop(@$('.body')[0].scrollHeight)

  showUnread: () ->
    _.each @channel.message_buffer, (msg) =>
      @receiveMessage(msg)
    @channel.message_buffer.splice(0, @channel.message_buffer.length)
    @receiveHisMessage(@channel.unread_buffer) if @channel.unread_buffer['msgs'].length > 0
    @channel.unread_buffer = { theEnd: true, msgs: [] };

  showWithMsg: () ->
    @resetHistory()
    @showDialog()

  bindMessage: () ->
    @channel.onMessage(@receiveMessage, @)

  bindSysMsg: () ->
    @channel.onSysMsg(@receiveSysMsg, @)

  unbindMessage: () ->
    @channel.removeEventListener('message', @receiveMessage)

  activeDialog: () ->
    @model.trigger('unactive_avatar')
    @$el.css('z-index', 10000)
    @$el.siblings('.global_chat').css('z-index', 9999)

  online: () ->
    @state_el.addClass(@on_class).removeClass(@off_class)

  offline: () ->
    @state_el.addClass(@off_class).removeClass(@on_class)

  fastKey: (event) ->
    @sendInputing()
    @sendMessage(event) if event.ctrlKey && event.keyCode == 13

  sendImg: (photo) ->
    return if _.isEmpty(photo)
    @channel.send(msg: '', attachments: [ photo ])

  sendMessage: (event) ->
    msg = @sendContent().val().trim()
    return if msg is ''
    @channel.send(msg)
    @sendContent().val('')


class root.FriendChatView extends BaseChatView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Chat.of(@name)

  stateService: () ->
    $(window).bind('idle', () =>
      @sendState('away')
    )
    $(window).bind('active', () =>
      @sendState('online')
    )
    window.clients.on 'connect', (error) => 
      @sendState('online')
    window.clients.on 'disconnect', (error) => 
      @sendState('away')

  # 通知对方自己的在线状态
  sendState: (state) ->
    @channel.online_state(state)

  sendInputing: (time = 30000) ->
    @activeTime ||= new Date().getTime()
    if new Date().getTime() - @activeTime > time
      @channel.being_input()
      @activeTime = new Date().getTime()


class root.GroupChatView extends BaseChatView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Group.of(@name)


class root.TemporaryChatView extends BaseChatView

  initialize: () ->
    super

  getChannel: () ->
    @channel ||= Caramal.Temporary.of(@name)


class root.OrderChatView extends Caramal.BackboneView
  on_class: 'online'
  off_class: 'offline'
  className: 'order_chat'

  EVENT_TYPE: {
    'joined'     : 1,
    'leaved'     : 2,
    'inputing'   : 3,
    'onlineState': 4
  }

  events:
    'mouseover '                : 'activeDialog'
    'click .close_label'        : 'hideDialog'
    'click .send_button'        : 'sendMessage'
    'click .emojify-chooser img': 'chooseEmojify'
    'keyup textarea.content'    : 'fastKey'

  # history_tip: _.template('<li class="text-center">-----<%= text %>-----</li>')

  chat_template:  _.template('
    <div class="body">
      <ul class="msg_content">
      </ul>
    </div>
    <div class="foot">
      <div class="send_content">
        <textarea class="content"></textarea>
      </div>
      <div class="foot_nav">
        <span class="face-panel">
          <a href="javascript:void(0)" class="btn choose-face" data-toggle="popover" data-trigger="click" data-placement="top" data-html="true" data-original-title="">
            <i class="icon-glass"></i>
          </a>
        </span>
        <span class="upload-panel">
          <i class="icon-picture upload-image"></i>
        </span>
        <button class="btn btn-primary send_button">发送</button>
      </div>
    </div>')

  sys_msg_template: _.template("
    <li>
      <div class='alert alert-info'>
        <i class='icon-info-sign'></i>系统消息：<%= message.msg %>
      </div>
    </li>")

  receive_template: Handlebars.compile('
    <li clas="row-receive">
      <div class="pull-left">
        <div class="icon">
          <img src="/default_img/t5050_default_avatar.jpg">
        </div>
      </div>
      <div class="message-body">
        <div class="pull-left">
          <a href="#" class="login">{{ user }}</a>
          {{calender time}}
        </div>
        <div class="message">
          {{ msg }}
          {{#each attachments}}
            <a class="image-zoom" target="_blank" href="{{default}}">
              <img src="{{header}}" alt="图片">
            </a>
          {{/each}}
        </div>
      </div>
    </li>')

  # fetchHistory: () ->
  #   @msgLoaded ||= false
  #   return if @msgLoaded
  #   start = @channel.message_buffer.length + 1
  #   @channel.history({start: start}, (chat, err, messages) =>
  #     @msgLoaded = true
  #     $html = @parseMessages(messages)
  #     text = if $html is '' then '没有聊天记录' else '以上是聊天记录'
  #     $html += @history_tip({text: text})
  #     @msgContent().prepend($html)
  #     @$('.message .image-zoom').fancybox()
  #     @scrollDialog()
  #   )

  # resetHistory: () ->
  #   @msgLoaded = false
  #   @msgContent().html('')
  #   @fetchHistory()


  initialize: (options) ->
    super
    @name = @model.get('name')
    @title = @name unless @title
    @channel = @model.get('channel')
    return pnotify(type: 'error', text: '请求聊天失败，name为空') unless @name
    @initChannel()
    @initDialog()
    # $(@el).bind('enterOrderChat', () =>
    #   int = window.setInterval( () =>
    #     if !@msgLoaded && @channel_ready
    #       window.clearInterval(int)
    #       @showWithMsg()
    #   , 300)
    # )

  initChannel: () ->
    @channel ||= Caramal.Temporary.of(@name)
    @channel.open( () =>
      @channel.record()
      @channel_ready = true
      $(@el).trigger('enterOrderChat')
    )

  initDialog: () ->
    # @bindMessage()
    $(@el).html(@chat_template({model: @model}))
    @model.chat_view = @
    @display = false
    $(@model.get('attach_el')).append(@el)

    ChatManager.getInstance().collection.add(@model)
    new ImageUpload({ el: @el, parent_view: @ })
    @$('.choose-face').popover({
      content: () => EmojifyChooser.getInstance().el
    })
    $(@el).hide()

  chooseEmojify: (event) ->
    @$('.choose-face').popover('hide')
    @sendContent().insertAtCursor(":#{$(event.target).data('name')}:")

  parseOne: (message) ->
    if message.user is clients.current_user
      html = @receive_template(message)
    else
      html = @receive_template(message)

    html.replace(/:([a-z]|_)+:/g, (word) =>
      '<img src="/assets/emojis/' + word.replace(/:/g, '') + '.png" class="emoji"/>'
    )

  parseMessages: (messages) ->
    html = ''
    messages = [messages] unless $.isArray(messages)
    _.each messages, (message) =>
      html += @parseOne(message)  
    html

  parseSysMsg: (message) ->
    @sys_msg_template({ message: message })

  sendContent: () ->
    @$('.content')

  msgContent: () ->
    @$('.msg_content')

  receiveMessage: (data) ->
    if @display
      @msgContent().append(@parseMessages(data))
      @model.trigger('active_avatar') if @name is data.user
      @$('.message .image-zoom').fancybox()
      @scrollDialog()

  receiveSysMsg: (data) ->
    if @display
      @msgContent().append(@parseSysMsg(data))
      @model.trigger('active_avatar') if @name is data.user
      @$('.message .image-zoom').fancybox()
      @scrollDialog()

  toggleDialog: () ->
    if @display
      @hideDialog()
    else
      @showWithMsg()

  hideDialog: () ->
    $(@el).hide()
    @display = false
    @msgContent().html('')
    @channel.deactive()
    # @unbindMessage()

  showDialog: () ->
    $(@el).show()
    @display = true
    @channel.active()
    @showUnread()
    # @bindMessage()
    @scrollDialog()

  scrollDialog: () ->
    @$('.body').scrollTop(@$('.body')[0].scrollHeight)

  showUnread: () ->
    _.each @channel.message_buffer, (msg) =>
      @receiveMessage(msg)
    @channel.message_buffer.splice(0, @channel.message_buffer.length)

  showWithMsg: () ->
    # @resetHistory()
    @showDialog()

  bindMessage: () ->
    @channel.onMessage(@receiveMessage, @)

  bindSysMsg: () ->
    @channel.onSysMsg(@receiveSysMsg, @)

  unbindMessage: () ->
    @channel.removeEventListener('message', @receiveMessage)

  activeDialog: () ->
    @model.trigger('unactive_avatar')
    @$el.css('z-index', 10000)
    @$el.siblings('.global_chat').css('z-index', 9999)

  fastKey: (event) ->
    @sendMessage(event) if event.ctrlKey && event.keyCode == 13

  sendImg: (photo) ->
    return if _.isEmpty(photo)
    @channel.send(msg: '', attachments: [ photo ])

  sendMessage: (event) ->
    msg = @sendContent().val().trim()
    return if msg is ''
    @channel.send(msg)
    @sendContent().val('')

