define ["faye", "lib/underscore"], ( faye, d) ->

  root = (window || @)
  root.clients = {}

  class RealtimeClient

    constructor: (server_uri = null) ->
      @client = new Faye.Client(server_uri) if server_uri?
      @events = {}

    monitor_people_notification: (token, callback = (data) -> ) ->
      @subscribe("/notification/#{token}", (data) ->
        callback(data)
      )

    monitor_event: (event_name, token, callback = (data) ->) ->
      @subscribe("/events/#{token}/#{event_name}", (data) ->
        callback(data)
      )

    subscribe: (path, handle) ->
      console.log @events
      @events[path] ?= []
      handles = @events[path]
      if handles? && _(handles).isArray()
        handle_str = handle.toString()
        console.log handles
        console.log handle_str
        unless _(handles).contains(handle_str)
          handles.push handle_str
          @client.subscribe(path, handle)





  root.client = (uri) ->
    @clients[uri] ?= new RealtimeClient(uri)

  root

