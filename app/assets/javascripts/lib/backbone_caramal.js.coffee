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
  msgLoaded: false

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

  resetHistory: () ->
    @msgContent().html('')

  initialize: (options) ->
    super
    @render()
    @name = @model.get('name')
    @title = @name unless @title
    @channel = @model.get('channel')
    return pnotify(type: 'error', text: '请求聊天失败，name为空') unless @name
    @bindEvent()
    @initChannel()
    @initDialog()

  getChannel: () ->
    # @bindMessage()
    @bindSysMsg()
    @bindHisMsg()

  initChannel: () ->
    @getChannel()
    @channel.open( () =>
      @channel.record()
      @channel_ready = true
    )

  initDialog: () ->
    @bindScroll()
    @setDisplay()
    $('body').append(@el)
    @state_el = @$(".head>.state")
    @addResizable()

    @addModelToManager()
    @setImgUploader()
    @hide()

  render: () ->
    $(@el).html(@chat_template({model: @model}))

  bindScroll: () ->
    @$('div.body').scroll($.proxy(@moreHisMsgs, @))

  setDisplay: () ->
    @model.chat_view = @
    @display = false

  addModelToManager: () ->
    ChatManager.getInstance().addModel(@model)

  setImgUploader: () ->
    new ImageUpload({ el: @el, parent_view: @ })
    @$('.choose-face').popover({
      content: () => EmojifyChooser.getInstance().el
    })

  hide: () ->
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

  receiveHisMessage: (msgs) ->
    origin_height = @$('.body')[0].scrollHeight
    @msgContent().prepend(@parseMessages(msgs))
    @showMoreFlag()
    setTimeout () =>
      height = @$('.body')[0].scrollHeight
      diff = height - origin_height
      @$('.body').scrollTop(diff)


    # @model.trigger('active_avatar') if @name is msgs.user
    if @display
      @$('.message .image-zoom').fancybox()
      # @scrollDialog()

  moreHisMsgs: (event) ->
    target = event.target || event.srcElement
    if $(target).scrollTop() < 5
      setTimeout(() =>
        @channel.fetchMsgs() if $(target).scrollTop() < 5
      , 800)

  showMoreFlag: () ->
    moreFlag = @msgContent().find('.showMoreFlag')
    moreFlag.remove()
    @msgContent().prepend("<li class='row-receive showMoreFlag'>\
      <i class='icon-time'></i>查看更多信息</li>")

  removeMoreFlag: () ->
    @msgContent().find('.showMoreFlag').remove()

  toggleDialog: () ->
    if @display
      @hideDialog()
    else
      @showWithMsg()

  hideDialog: () ->
    $(@el).hide()
    @resetHistory()
    @display = false
    @channel.resetHisInitTime()
    @channel.deactive()
    # @unbindMessage()


  showDialog: () ->
    $(@el).show()
    @display = true
    @channel.active()
    @addBufferMsgs()
    @channel.on 'endOfHisMsg', (event) =>
      @removeMoreFlag();
    setTimeout () =>
      @scrollDialog()

  scrollDialog: () ->
    @$('.body').scrollTop(@$('.body')[0].scrollHeight)

  addBufferMsgs: () ->
    @addHisBufMsgs()
    @addNewBufMsgs()

  addHisBufMsgs: () ->
    @receiveHisMessage(@channel.hisMsgBuf)
    @channel.emptyHisBuf()

  addNewBufMsgs: () ->
    @receiveMessage(@channel.message_buffer)
    @channel.emptyNewBuf()

  showWithMsg: () ->
    @showDialog()

  # bindMessage: () ->
  #   @channel.onMessage(@receiveMessage, @)

  bindSysMsg: () ->
    @channel.onSysMsg(@receiveSysMsg, @)

  bindHisMsg: () ->
    @channel.on 'hisMsgsFetched', (event) =>
      @addBufferMsgs()

  # unbindMessage: () ->
  #   @channel.removeEventListener('message', @receiveMessage)

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
  getChannel: () ->
    @channel ||= Caramal.Chat.of(@name)
    super

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
  getChannel: () ->
    @channel ||= Caramal.Group.of(@name)
    super

class root.TemporaryChatView extends BaseChatView
  getChannel: () ->
    @channel ||= Caramal.Temporary.of(@name)
    super


class root.OrderChatView extends BaseChatView
  className: 'order_chat'

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
    @getChannel()
    @channel.open( () =>
      @channel.record()
      @channel_ready = true
      $(@el).trigger('enterOrderChat')
    )

  getChannel: () ->
    @channel ||= Caramal.Temporary.of(@name)
    super

  initDialog: () ->
    @render()
    @bindScroll()
    @setDisplay()
    $(@model.get('attach_el')).append(@el)

    @addModelToManager()
    @setImgUploader()
    @hide()

  fastKey: (event) ->
    @sendMessage(event) if event.ctrlKey && event.keyCode == 13