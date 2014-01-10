
root = (window || @)

class root.TransactionRealTime

  constructor: (shop_key, type) ->
    @type = type
    @shop_key = shop_key
    @client = window.clients

  url_root: () ->
    "/shops/#{@shop_key}/#{@type}"

  create: (callback) ->
    @client.monitor "#{@url_root()}/create", (data) =>
      callback(data) if $.isFunction(callback)

  dispose: (callback) ->
    @client.monitor "#{@url_root()}/dispose", (data) =>
      callback(data) if $.isFunction(callback)

  destroy: (callback) ->
    @client.monitor "#{@url_root()}/destroy", (data) =>
      callback(data) if $.isFunction(callback)

  change_state: (id, callback) ->
    @client.monitor "#{@url_root()}/#{id}/change_state", (data) =>
      callback(data) if $.isFunction(callback)

  change_info: (id, callback) ->
    @client.monitor "#{@url_root()}/#{id}/change_info", (data) =>
      callback(data) if $.isFunction(callback)



