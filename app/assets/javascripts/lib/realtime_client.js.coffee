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
      console.log("connected.")
    )
    @on('disconnect', (error) =>
      console.error("disconnect: " + error)
      alert("disconnect: " + error) if error
    )

  connect: () ->
    @client = Caramal.connect(@url, @options)

  on: (event, callback) ->
    @client.on(event, callback)

  subscribe: (channel, callback) ->
    @on(channel, callback)

  unsubscribe: (channel) ->
    @client.removeListener(channel)

  emit: (event, data, callback) ->
    @client.emit(event, data, callback)

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

