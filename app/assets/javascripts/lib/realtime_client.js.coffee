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
      @connected(500)
      @connected_state()
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
      @connected(2000)
      @connected_state()
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

  unmonitor: () ->
    @socket.unNotify(channel,callback)

  monitor: (channel,callback) ->
    @socket.onNotify(channel,callback)

  disconnect_state: () ->
    # 订单聊天窗口
    $("iframe").contents().find("body [data-realtime-state]").each () ->
      $(@).attr("data-realtime-state", "disconnect").attr("readonly","readonly")
      $(@).tooltip({'trigger':'focus', 'title': '此窗口已经失效，请刷新'})

  connected_state: () ->
    $("iframe").contents().find("body [data-realtime-state]").each () ->
      $(@).removeAttr("readonly")
      $(@).removeData("tooltip")

  connecting: () ->
    $(".login_bar").css("width","100%")
    $(".login_progress").removeClass("progress-danger").addClass("active").show()
    target = $(".realtime_state")
    target.popover('hide')
    target.removeData("popover")
    target.popover({
        content: "连接中...",
        placement: "bottom",
        trigger: "hover"
      })
    target.popover("show")

  connected: (time) ->
    $(".realtime_state").popover('hide')
    $(".realtime_state").removeData("popover")
    $(".user_icon").removeClass("disconnect")
    setTimeout( () ->
      $(".login_progress").hide()
    ,time);

  error_tip: (type) ->
    $(".user_icon").addClass("disconnect")
    target = $(".login_progress")
    unless type == "booted"
      target.find(".login_bar").css("width","100%")
      target.addClass("progress-danger").removeClass("active").show()
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
        content: message+"点击<a href='#' class='connect_by_self'>重连</a>",
        placement: "bottom",
        html: true,
        trigger: "hover"
      })
    target.popover("show")
    setTimeout( () ->
      target.popover("hide")
    ,5000);
