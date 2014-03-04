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
  iconArr: []

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
    'click .head .name'         : 'clickTitle'

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
          <img class="{{user}}" src="{{icon}}" title="{{user}}" />
        </div>
      </div>
      <div class="message-body">
        <div class="pull-left">
          <a href="#" class="{{user}}">{{user}}</a>
          {{calender time}}
        </div>
        <div class="message">
          {{ msg }}
          {{#each attachments}}
            <a class="image-zoom unloaded" target="_blank" href="{{default}}">
              <img src="{{header}}" alt="图片">
            </a>
          {{/each}}
        </div>
      </div>
    </li>')

  clickTitle: () ->

  resetHistory: () ->
    @msgContent().html('')

  initialize: (options) ->
    super
    @render()
    @name = @model.get('title')
    @title = @name unless @title
    # @channel = @model.get('channel')
    return pnotify(type: 'error', text: '请求聊天失败') unless @name
    @initChannel()
    @bindEvent()
    @initDialog()

  getChannel: () ->
    # @bindMessage()

  initChannel: () ->
    @getChannel()
    @bindSysMsg()
    @bindHisMsg()
    unless @channel.getState() is 'open'
      @channel.open () =>
        @channel.record()
        @channel_ready = true

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
    head_html = @head_template({model: @model})
    chat_html = @chat_template({model: @model})
    $(@el).html(head_html + chat_html)

  bindScroll: () ->
    @$('div.body').bind('mousewheel', $.proxy(@disablePageScroll, @))
    @$('div.body').bind('mousewheel', $.proxy(@moreHisMsgs, @))

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
    user = message.user
    if user is clients.current_user
      html = @receive_template(message)
    else
      html = @receive_template(message)

    html.replace /:([a-z]|_)+:/g, (word) =>
      '<img src="/assets/emojis/' + word.replace(/:/g, '') + '.png" class="emoji"/>'

  fetchIcon: () ->
    _.each @iconArr, (user) =>
      ChatManager.getInstance().getIcon user, () =>
        user_icon = ChatManager.iconList["#{user}"]
        @$(".icon>img.#{user}").attr('src', user_icon)

  parseMessages: (messages) ->
    html = ''
    messages = [messages] unless $.isArray(messages)
    _.each messages, (message) =>
      user = message.user
      if @iconArr.contain(user)
        message.icon = ChatManager.iconList["#{user}"]
        html += @parseOne(message)
      else
        @iconArr.push(user)
        message.icon = '/default_img/t5050_default_avatar.jpg'
        html += @parseOne(message)
    $(html)

  parseSysMsg: (message) ->
    @sys_msg_template({ message: message })

  sendContent: () ->
    @$('.content')

  msgContent: () ->
    @$('.msg_content')

  receiveMessage: (data) ->
    $html = @parseMessages(data)
    @msgContent().append($html)
    @fetchIcon()
    @model.trigger('active_avatar') if @name is data.user
    @scrollDialog()

  receiveSysMsg: (data) ->
    if @display
      @msgContent().append(@parseSysMsg(data))
      @model.trigger('active_avatar') if @name is data.user
      @scrollDialog()

  receiveHisMessage: (msgs) ->
    return if msgs.length is 0
    origin_height = @$('.body')[0].scrollHeight
    @msgContent().prepend(@parseMessages(msgs))
    @fetchIcon()
    @dealWithMoreFlag()
    setTimeout () =>
      height = @$('.body')[0].scrollHeight
      diff = height - origin_height
      @$('.body').scrollTop(diff)

    if @display
      @$('.message .image-zoom.unloaded').fancybox()

  disablePageScroll: (event) ->
    top = @$('.body').scrollTop()
    delta = event.originalEvent.wheelDelta
    height = @$('.body').height()
    scrollHeight = @$('.body')[0].scrollHeight
    if (delta > 0 && top <= 0)
      return false
    else if (delta < 0 && top >= scrollHeight - height)
      return false

  moreHisMsgs: (event) ->
    target = event.target || event.srcElement
    if $(target).scrollTop() < 5
      setTimeout(() =>
        @channel.fetchMsgs() if $(target).scrollTop() < 5
      , 800)

  dealWithMoreFlag: () ->
    if @channel.hisMsgEnded
      @removeMoreFlag()
    else
      @showMoreFlag()

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
      @showDialog()

  hideDialog: () ->
    $(@el).hide()
    # @resetHistory()
    @display = false
    # @channel.resetHisInitTime()
    @channel.deactive()
    # @unbindMessage()

  showDialog: () ->
    $(@el).show()
    @display = true
    @channel.active()
    @addBufferMsgs()

  _scrollDialog: () =>
    @$('.body').scrollTop(@$('.body')[0].scrollHeight)

  scrollDialog: () ->
    $img_zoom = @$('.message .image-zoom.unloaded')
    if $img_zoom.length is 0
      @_scrollDialog()
    else
      $img_zoom.removeClass('unloaded')
      $img_zoom.find('>img').one 'load', () =>
        $img_zoom.fancybox()
        @_scrollDialog()

  addBufferMsgs: () ->
    @addHisBufMsgs()
    @addNewBufMsgs()
    @scrollDialog()

  addHisBufMsgs: () ->
    @receiveHisMessage(@channel.hisMsgBuf)
    @channel.emptyHisBuf()

  addNewBufMsgs: () ->
    @receiveMessage(@channel.message_buffer)
    @channel.emptyNewBuf()

  # showWithMsg: () ->
  #   @showDialog()

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
  head_template: _.template('
    <div class="head">
      <span class="state online"></span>
      <a class="name" href="javascript: void(0)"><%= model.get("displayTitle") %></a>
      <span class="input_state"></span>
      <a class="close_label" href="javascript:void(0)"></a>
    </div>')

  clickTitle: () ->
    window.location.href = "/people/#{@title}"

  getChannel: () ->
    @channel ||= Caramal.Chat.of(@title)

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
  head_template: _.template('
    <div class="head">
      <a class="name" href="javascript: void(0)"><%= model.get("displayTitle") %></a>
      <a class="close_label" href="javascript:void(0)"></a>
    </div>')

  getChannel: () ->
    @channel ||= Caramal.Group.of(@name)

  clickTitle: () ->
    $.ajax(
      type: 'POST'
      dataType: 'json'
      data: { name: @name }
      url: "/communities/index_url"
      success: (data, xhr, res) =>
        return if _.isEmpty(data.url)
        document.location.href = data.url
      error: (data, xhr, res) =>
        pnotify(type: 'error', text: '跳转失败')
    )


class root.TemporaryChatView extends BaseChatView
  head_template: _.template('
    <div class="head">
      <span class="state online"></span>
      <a class="name" href="javascript: void(0)"><%= model.get("displayTitle") %></a>
      <span class="input_state"></span>
      <a class="close_label" href="javascript:void(0)"></a>
    </div>')

  getChannel: () ->
    @channel ||= Caramal.Temporary.of(@name)

  clickTitle: () ->
    title = @model.get('title')
    number = title.substring(title.indexOf('_') + 1, title.length)
    return if _.isEmpty(number)
    id = number.replace(/\D/, '')
    type = title.substring(0, title.indexOf('_'))
    $.ajax(
      type: 'POST'
      url: "/transaction/#{id}/operate_url/#{type}"
      success: (data, xhr, res) =>
        return if _.isEmpty(data.url)
        document.location.href = data.url
      error: (data, xhr, res) =>
        pnotify(type: 'error', text: '跳转到订单失败')
    )


class root.OrderChatView extends BaseChatView
  className: 'order_chat'

  head_template: _.template('')

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

  disablePageScroll: (event) ->

  initialize: (options) ->
    @name = @model.get('title')
    @title = @name unless @title
    @channel = @model.get('channel')
    return pnotify(type: 'error', text: '请求聊天失败') unless @name
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
    @bindSysMsg()
    @bindHisMsg()
    unless @channel.getState() is 'open'
      @channel.open (chat, err, room) =>
        @channel.record()
        @channel_ready = true
        $(@el).trigger('enterOrderChat')

  getChannel: () ->
    @channel ||= Caramal.Temporary.of(@name)

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

