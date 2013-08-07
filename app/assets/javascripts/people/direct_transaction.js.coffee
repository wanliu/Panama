
class window.DirectTransactionView extends Backbone.View
  events: {
    "click .direct-message button"  : "toggle_message"
    "click .direct-info .completed" : "completed"
    "click .direct-info .close"     : "close"
  }

  initialize: () ->
    @$info = @$(".direct-info")
    @login = @options.login
    @$el = $(@el)
    @$message = @$(".direct-message")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")
    @direct_transaction_id = @$el.attr("data-value-id")
    @load_style()

  load_style: () ->
    @$iframe.height(@$info.height() - @$toolbar.height())

  toggle_message: () ->
    @$messages.slideToggle()

  completed: () ->
    $.ajax(
      url: "/people/#{@login}/direct_transactions/#{@direct_transaction_id}/completed",
      type: 'POST',
      success: () =>
        @el.remove()
    )

  close: () ->
    if confirm("是否确认删除交易?")
      $.ajax(
        url: "/people/#{@login}/direct_transactions/#{@direct_transaction_id}",
        type: "DELETE",
        success: () =>
          @el.remove()
      )




