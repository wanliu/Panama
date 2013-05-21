define ["faye", "lib/underscore"], ( faye, d) ->

  root = (window || @)
  root.clients = {}

  class RealtimeClient

    constructor: (server_uri = null) ->
      @client = new Faye.Client(server_uri) if server_uri?
      @client.setHeader('Authorization', 'OAuth abcd-1234');
      @events = {}

    monitor_people_notification: (token, callback = (data) -> ) ->
      @subscribe("/notification/#{token}", (data) ->
        callback(data)
      )

    online: (id, callback) ->
      @subscribe("/chat/friend/connect/#{id}", callback)

    offline: (id, callback) ->
      @subscribe("/chat/friend/disconnect/#{id}", callback)

    #接收信息
    receive_message: (token, callback) ->
      @subscribe("/chat/receive/#{token}", callback)

    monitor_event: (event_name, token, callback = (data) ->) ->
      @subscribe("/events/#{token}/#{event_name}", (data) ->
        callback(data)
      )

    subscribe: (path, handle) ->
      @events[path] ?= []
      handles = @events[path]
      if handles? && _(handles).isArray()
        handle_str = handle.toString()
        unless _(handles).contains(handle_str)
          handles.push handle_str
          @client.subscribe(path, handle)

  root.client = (uri) ->
    @clients[uri] ?= new RealtimeClient(uri)

  root


