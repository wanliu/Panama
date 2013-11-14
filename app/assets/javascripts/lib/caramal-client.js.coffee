#= require lib/socket.io

root = window || @

class root.CaramalClient

  @connect = (options) ->
    CaramalClient.globalClient ||= new CaramalClient(options)

  constructor: (options) ->
    _.extend(@, options)
    if @token?
      @url = @uri + '?token=' + @token
    @connect()

    @on('connect', () =>
      console.log("connected.")
    )
    @on('disconnect', (error) =>
      alert("disconnect: " + error) if error      
    )

  connect: () ->
    @socket = io.connect(@url, @options)

  on: (event, callback) ->
    @socket.on(event, callback)

  subscribe: (channel, callback) ->
    @on(channel, callback)

  unsubscribe: (channel) ->
    @socket.removeListener(channel)

  emit: (event, data, callback) ->
    @socket.emit(event, data, callback)

