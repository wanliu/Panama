#= require lib/socket.io

root = (window || @)

class CaramalClient

  @connect = (options) ->
    CaramalClient.globalClient ||= new CaramalClient(options)

  constructor: (@options) ->
    @url = @options.url
    if @options.token?
      @url = @url + '?token=' + @options.token
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

root.CaramalClient = CaramalClient
