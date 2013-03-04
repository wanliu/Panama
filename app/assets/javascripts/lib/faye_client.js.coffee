define(["faye"], () ->
    realtime = new Faye.Client('/realtime');
    realtime.subscribe("/notice/transactions", (data) ->

    )
    realtime
)