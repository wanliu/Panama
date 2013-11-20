#= require lib/caramal_chat

root = (window || @)

class root.Realtime

  @connect = (options) ->
    Realtime.globalClient ||= new Realtime(options)

  constructor: (options) ->
    _.extend(@, options)
    @url = @server_uri + '?token=' + @token
    @client = @connect() if @server_uri?
    @events = {}

    @on('connect', () =>
      window.$(".user_icon").removeClass("disconnect")
      console.log("connected.")
    )
    @on('disconnect', (error) =>
      console.error("disconnect: " + error)
      @disconnect_tip()
      @disconnect_state()
    )
    @on('connecting', () =>
      console.log('connecting')
    )
    @on('connect_failed', () =>
      console.log('connect_failed')
    )
    @on('error', (err) =>
      console.log('error:' + err)
    )
    @on('reconnect', () ->
      console.log('reconnect') 
    )
    @on('reconnecting', () ->
      console.log('reconnecting')
    )

  disconnect_tip: () ->
    window.$(".user_icon").addClass("disconnect")
    $("<div class='disconnect_message'>此页面已经失效,如果是想激活本页面，请点击<a href='javascript:window.location.reload()'>刷新</a>页面</div>").insertBefore("body")

  connect: () ->
    @socket = Caramal.connect(@url, @options)

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
      $(@).attr("data-realtime-state", "disconnect")
      $(this).tooltip({'trigger':'focus', 'title': '此页面已经失效，请刷新'});




