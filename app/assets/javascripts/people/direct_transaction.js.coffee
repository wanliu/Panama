root = (window || @)

class Direct extends Backbone.Model


class root.DirectTransactionView extends Backbone.View
  events: {
    "click .direct-message button"  : "toggle_message"
    "click .direct-info .completed" : "completed"
  }

  initialize: () ->
    @$info = @$(".direct-info")
    @login = @options.login
    @$el = $(@el)
    @$message = @$(".direct-message")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")
    @model = new Direct(id: @$el.attr("data-value-id"))

    @load_style()

  load_style: () ->
    setTimeout () =>
      padding = parseInt(@$message.css("padding-bottom")) + parseInt(@$message.css("padding-top"))
      @$messages.height(@$info.outerHeight() - @$toolbar.outerHeight() - padding)
    , 60

  toggle_message: () ->
    @$messages.slideToggle()

  completed: () ->
    $.ajax(
      url: "/people/#{@login}/direct_transactions/#{@model.id}/completed",
      type: 'POST',
      success: () =>
        @$(".wrap_event").html("<h4 class='pull-right'>交易成功</h4>")
    )