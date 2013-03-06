define(["faye"], () ->

    class RealtimeClient

        constructor: () ->
            @client = new Faye.Client('/realtime')

        monitor_people_notification: (uid, callback = (data) -> ) ->
            @client.subscribe("/notification/#{uid}", (data) ->
                callback(data)
            )



    new RealtimeClient
)