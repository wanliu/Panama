define(["faye"], () ->

    class RealtimeClient

        constructor: (server_uri) ->
            @client = new Faye.Client(server_uri)

        monitor_people_notification: (uid, callback = (data) -> ) ->
            @client.subscribe("/notification/#{uid}", (data) ->
                callback(data)
            )

        monitor_event: (event_name, uid, callback = (data) ->) ->
            @client.subscribe("/events/#{uid}/#{event_name}", (data) ->
                callback(data)
            )

    RealtimeClient
)