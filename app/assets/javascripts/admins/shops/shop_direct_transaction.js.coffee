root = (window || @)

class root.ShopDirectTransactionView extends Backbone.View
  events: {
    "click .direct-message button" : "toggle_message"
  }

  initialize: (options) ->
    _.extend(@, options)
    @init_elem()

    @model = new Backbone.Model(
      state: @$el.attr("state-name"),
      id: @$el.attr("data-value-id"))

    @model.bind("change:state", @change_state, @)
    @load_realtime()
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
    , 60

  toggle_message: () ->
    @$messages.slideToggle()

  change_state: () ->
    $(".state_title", @$info).html(@model.get("state_title"))

  load_realtime: () ->
    @client = window.clients.socket

    @client.subscribe "notify:/#{@shop.token}/direct_transactions/#{@model.id}/change_state", (data) =>
      @model.set(
        state: data.state,
        state_title: data.state_title
      )
