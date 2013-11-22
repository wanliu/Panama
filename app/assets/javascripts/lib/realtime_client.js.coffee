#= require lib/caramal_chat

root = (window || @)

class root.Realtime

  @connect = (options) ->
    Realtime.globalClient ||= new Realtime(options)

  constructor: (options) ->
    _.extend(@, options)
    @url = @server_uri + '?token=' + @token
    @connect()
    @events = {}

    @on('connect', () =>
      @connected()
      console.log("connected.")
    )

    @on('disconnect', (error) =>
      @error_tip(error)
      @disconnect_state()
      console.error("disconnect: " + error)
    )

    @on('connecting', () =>
      @connecting()
      console.log('connecting')
    )

    @on('connect_failed', () =>
      @error_tip("connect_failed")
      @disconnect_state()
      console.log('connect_failed')
    )
    @on('error', (err) =>
      @error_tip(err)
      @disconnect_state()
      console.log('error:' + err)
    )
    @on('reconnect', () =>
      @connected()
      console.log('reconnect') 
    )
    @on('reconnecting', () =>
      @connecting()
      console.log('reconnecting')
    )

  connect: () ->
    @socket = Caramal.connect(@url, @options)
    Caramal.MessageManager.setClient(@socket)

  on: (event, callback) ->
    @socket.on(event, callback)

  subscribe: (channel, callback) ->
    @on(channel, callback)

  unsubscribe: (channel) ->
    @socket.removeListener(channel)

  emit: (event, data, callback) ->
    @socket.emit(event, data, callback)

  monitor_people_notification: (im_token, callback = (data) -> ) ->
    @subscribe("/notification/#{im_token}", (data) ->
      callback(data)
    )

  online: (id, callback) ->
    @subscribe("/chat/friend/connect/#{id}", callback)

  offline: (id, callback) ->
    @subscribe("/chat/friend/disconnect/#{id}", callback)

  receive_message: (token, callback) ->
    @subscribe("/chat/receive/#{token}", callback)

  monitor_event: (event_name, token, callback = (data) ->) ->
    @subscribe("/events/#{token}/#{event_name}", (data) ->
      callback(data)
    )

  disconnect_state: () ->
    # 订单聊天窗口
    $("iframe").contents().find("body [data-realtime-state]").each () ->
      $(@).attr("data-realtime-state", "disconnect").attr("readonly","readonly")
      $(@).tooltip({'trigger':'focus', 'title': '此窗口已经失效，请刷新'})

  connecting: () ->
    $(".progress").show()

  connected: () ->
    $(".realtime_state").popover('hide').removeData("popover")
    $(".user_icon").removeClass("disconnect")
    $(".progress").hide()
      
  error_tip: (type) ->
    $(".user_icon").addClass("disconnect")
    target = $(".progress")
    unless type == "booted"
      target.find(".bar").css("width","50%")
      target.addClass("progress-danger").show()
      message = if type == undefined
        "链接错误，请稍后重试"
      else
        "连接失败, 请刷新重试"
    else
      message = "你帐号在异地登录"
    @tip_operate(message)

  tip_operate: (message) ->
    target = $(".realtime_state")
    target.removeData("popover")
    target.popover({
        content: message+"点击<a href='#' class='connect_by_self pull-right'>链接</a>",
        placement: "bottom",
        html: true,
        trigger: "hover"
      })
    target.popover("show")
    setTimeout( () ->
      target.popover("hide")
    ,5000);
