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
  input_name: "attachment_ids"
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
      @parent_view.sendImg(data.attachment.file.t100100.url)

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
    'click .send_button'        : 'sendMeessage'
    'click .emojify-chooser img': 'chooseEmojify'
    'keyup textarea.content'    : 'fastKey'

  history_tip: _.template('<li class="text-center">-----<%= text %>-----</li>')

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
          <a href="#" class="btn choose-face" data-toggle="popover" data-trigger="click" data-placement="top" data-html="true" data-original-title="">
            <i class="icon-glass"></i>
          </a>
        </span>
        <span class="upload-panel">
          <i class="icon-picture upload-image"></i>
        </span>
        <button class="btn btn-primary send_button">发送</button>
      </div>
    </div>')

  receive_template: Handlebars.compile('
    <li clas="row-receive">
      <div class="pull-left">
        <div class="icon">
          <img src="/default_img/t5050_default_avatar.jpg">
        </div>
      </div>
      <div class="message-body">
        <span class="arrow"></span>
        <div class="pull-left">
          <a href="#" class="login">{{ user }}</a>
          {{calender time}}
        </div>
        <div class="message">
          {{ msg }}
          {{#if attachments}}
            <img src="{{attachments}}" alt="图片" />
          {{/if}}
        </div>
      </div>
    </li>')

  send_template: Handlebars.compile('
    <li class="row-send">
      <div class="pull-right">
        <div class="icon">
          <img src="/default_img/t5050_default_avatar.jpg">
        </div>
      </div>
      <div class="message-body on-left">
        <span class="arrow"></span>
        <div class="pull-right">
          <a href="#" class="login">{{ user }}</a>
          {{calender time}}
        </div>
        <div class="message">
          {{ msg }}
          {{#if attachments}}
            <img src="{{attachments}}" alt="图片" />
          {{/if}}
        </div>
      </div>
    </li>')

  fetchHistory: () ->
    @msgLoaded ||= false
    return if @msgLoaded
    start = @channel.message_buffer.length + 1
    setTimeout( () =>
      @channel.history({start: start}, (chat, err, messages) =>
        @msgLoaded = true
        $html = @parseMessages(messages)
        text = if $html is '' then '没有聊天记录' else '以上是聊天记录'
        $html += @history_tip({text: text})
        @msgContent().prepend($html)
        @scrollDialog()
      )
    , 200)

  resetHistory: () ->
    @msgLoaded = false
    @msgContent().html('')
    @fetchHistory()

  initialize: (options) ->
    super
    @name = @model.get('name')
    @title = @name unless @title
    @channel = @model.get('channel')
    @initChannel()
    @initDialog()
    @bindEvent()

  initChannel: () ->
    console.log('unimplemented...')

  initDialog: () ->
    $(@el).html(@chat_template({model: @model}))
    @state_el = @$(".head>.state")
    @model.chat_view = @

    ChatManager.getInstance().addModel(@model)
    new ImageUpload({ el: @el, parent_view: @ })
    @$('.choose-face').popover({
      content: () => EmojifyChooser.getInstance().el
    })
    $(@el).hide()

  bindEvent: () ->
    @bindMessage()
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
    $(window).bind('enterAttachChat', () =>
      # $(@el).hide()
      # setTimeout( () =>
      #   @showDialog()
      # , 200)
    )

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
      html = @send_template(message)
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

  sendContent: () ->
    @targetEl(@el).find('.content')

  msgContent: () ->
    @targetEl(@el).find('.msg_content')

  targetEl: (el) =>
    $attach_el = $(@model.get('attach_el'))
    if $attach_el.length is 0
      $(el)
    else
      $([ $attach_el[0], el])

  receiveMessage: (data) ->
    # @msgContent().append(@parseMessages(data))
    if @displayState()
      @$('.msg_content').append(@parseMessages(data))
      @model.trigger('active_avatar') if @name is data.user
      @scrollDialog()

  getShowEl: () ->
    $attach_el = $(@model.get('attach_el'))
    if $attach_el.length is 1
      @newAttachView()
      if @isFullMode()
        return $(@attach_view.el)
    return $(@el)

  newAttachView: () ->
    @attach_view ||= new AttachChatView({
      model: @model,
      channel: @channel,
      el: $(@el).clone()
    })

  isFullMode: () ->
    $attach_el = $(@model.get('attach_el'))
    display = $attach_el.parents('.full-mode').is(':visible')
    $(@el).hide() if display
    display

  displayState: () ->
    @display = $(@el).is(':visible') || @isFullMode()
    if @display
      @channel.active()
    else
      @channel.deactive()
    @display

  toggleDialog: () ->
    @displayState()
    if @display
      @hideDialog()
    else
      @showWithMsg()

  hideDialog: () ->
    @getShowEl().slideToggle()
    @displayState()
    # @unbindMessage() if @display

  showDialog: () ->
    @getShowEl().slideDown()
    @displayState()
    @showUnread() if @display
    # @bindMessage() unless @display
    @scrollDialog()

  scrollDialog: () ->
    $body = @targetEl(@el).find('.body')
    $body.scrollTop($body[0].scrollHeight)

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
    @model.trigger('unactive_avatar')
    @$el.css('z-index', 10000)
    @$el.siblings('.global_chat').css('z-index', 9999)

  online: () ->
    @state_el.addClass(@on_class).removeClass(@off_class)

  offline: () ->
    @state_el.addClass(@off_class).removeClass(@on_class)

  fastKey: (event) ->
    @sendInputing()
    @sendMeessage(event) if event.ctrlKey && event.keyCode == 13

  sendImg: (url) ->
    return unless url
    @channel.send({ msg: '', attachments: [url] })

  sendMeessage: (event) ->
    # msg = @sendContent().val().trim()
    $msg = $(event.target).parents('.foot').find('textarea.content')
    msg = $msg.val().trim()
    return if msg is ''
    @channel.send(msg)
    @sendContent().val('')


class root.ChatView extends BaseChatView

  initialize: () ->
    super

  initChannel: () ->
    @channel ||= Caramal.Chat.of(@name)
    @channel.open()
    @channel.record()

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

  initChannel: () ->
    @channel ||= Caramal.Group.of(@name)
    @channel.open()
    @channel.record()


class root.TemporaryChatView extends BaseChatView

  initialize: () ->
    super

  initChannel: () ->
    @channel ||= Caramal.Temporary.of(@name)
    @channel.open()
    @channel.record()


class root.AttachChatView extends TemporaryChatView

  events:
    'mouseover '                : 'activeDialog'
    'click .close_label'        : 'hideDialog'
    'click .send_button'        : 'sendMeessage'
    'click .emojify-chooser img': 'chooseEmojify'
    'keyup textarea.content'    : 'fastKey'
 
  initialize: (options) ->
    _.extend(@, options)
    $(@el).removeAttr('style')
          .css('position', 'static')
          .css('width', '100%')
          .css('height', '100%')
          .find('.head').addClass('hide')
    $(@model.get('attach_el')).html(@el)

    @bindMessage()
    new ImageUpload({ el: @el, parent_view: @ })
    @$('.choose-face').popover({
      content: () => EmojifyChooser.getInstance().el
    })
    $(@el).hide()

