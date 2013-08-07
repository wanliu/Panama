
class window.ShopDirectTransactionView extends Backbone.View
  events: {
    "click .direct-message button" : "toggle_message"
  }

  initialize: () ->
    @$info = @$(".direct-info")
    @$message = @$(".direct-message")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")
    @load_style()

  load_style: () ->
    @$iframe.height(@$info.height() - @$toolbar.height())

  toggle_message: () ->
    @$messages.slideToggle()
