class window.ShopDirectTransactionView extends Backbone.View
  events: {
    "click .direct-message button" : "toggle_message"
  }

  initialize: (options) ->
    _.extend(@, options)
    @init_elem()
    @direct_transaction_id = @$el.attr("data-value-id")
    @realtime_load()
    @load_style()

  init_elem: () =>
    @$el = $(@el)
    @$info = @$(".direct-info")
    @$message = @$(".direct-message")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")

  load_style: () ->
    setTimeout () =>
      padding = parseInt(@$message.css("padding-bottom")) + parseInt(@$message.css("padding-top"))
      @$messages.height( @$info.outerHeight() - @$toolbar.outerHeight() - padding)
    , 200

  toggle_message: () ->
    @$messages.slideToggle()

  realtime_load: () ->
    # @client = Realtime.client(@realtime_url)
    @client = window.clients
    @client.subscribe "/DirectTransaction/#{@direct_transaction_id}/#{@shop.token}/#{@token}/destroy", () =>
      @remove()