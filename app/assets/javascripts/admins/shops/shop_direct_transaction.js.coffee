class window.ShopDirectTransactionView extends Backbone.View
  events: {
    "click .direct-message button" : "toggle_message"
  }

  initialize: (options) ->
    _.extend(@, options)
    @init_elem()
    @direct_transaction_id = @$el.attr("data-value-id")
    @load_style()
    @realtime_load()

  init_elem: () =>
    @$el = $(@el)
    @$info = @$(".direct-info")
    @$message = @$(".direct-message")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")

  load_style: () ->
    @$iframe.height(@$info.height() - @$toolbar.height())

  toggle_message: () ->
    @$messages.slideToggle()

  realtime_load: () ->
    @client = Realtime.client(@realtime_url)
    @client.subscribe "/DirectTransaction/#{@direct_transaction_id}/#{@shop.token}/#{@token}/destroy", () =>
      @remove()