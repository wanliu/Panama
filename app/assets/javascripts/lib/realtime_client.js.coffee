define(["faye"], () ->

  class RealtimeClient

    constructor: (server_uri) ->
      @client = new Faye.Client(server_uri)

    monitor_people_notification: (token, callback = (data) -> ) ->
      @client.subscribe("/notification/#{token}", (data) ->
        callback(data)
      )

    monitor_event: (event_name, token, callback = (data) ->) ->
      @client.subscribe("/events/#{token}/#{event_name}", (data) ->
        callback(data)
      )

  RealtimeClient
)