#= require 'lib/socket.io'

root = window || @
oldio = io
root.io = {
  connect: (url, details) ->
    new SocketIOPubSub(oldio.connect(url, details))

}

class SocketIOPubSub

  constructor: (@socket) ->
    # for name, method of @socket
    #   @[name] = () =>
    #     @socket[name].call(@, arguments)

  subscribe: (name, callback) ->
    @socket.on(name, callback)

  publish: (name, data, callback) ->
    @socket.emit(name, data, callback)

