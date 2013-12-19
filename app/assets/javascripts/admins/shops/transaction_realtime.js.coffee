
root = (window || @)

class root.TransactionRealTime

  constructor: (shop_key) ->
    @shop_key = shop_key
    @client = window.clients.socket

  url_root: () ->
    "notify:/shops/#{@shop_key}/order_transactions"

  create: (callback) ->
    @client.subscribe "#{@url_root()}/create", (data) =>
      callback(data) if $.isFunction(callback)

  dispose: (callback) ->
    @client.subscribe "#{@url_root()}/dispose", (data) =>
      callback(data) if $.isFunction(callback)

  destroy: (callback) ->
    @client.subscribe "#{@url_root()}/destroy", (data) =>
      callback(data) if $.isFunction(callback)

  chat: (callback) ->
    @client.subscribe "#{@url_root()}/chat", (data) =>
      callback(data) if $.isFunction(callback)

  change_state: (callback) ->
    @client.subscribe "#{@url_root()}/change_state", (data) =>
      callback(data) if $.isFunction(callback)


