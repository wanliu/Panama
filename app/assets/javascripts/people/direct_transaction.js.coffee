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
    @model = new Direct(
      state: @$el.attr("state-name"),
      id: @$el.attr("data-value-id"))

    @model.bind("change:state", @change_state, @)
    @load_realtime()
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
      success: (data) =>
        @model.set(
          state: data.state_name,
          state_title: data.state_title
        )
    )

  change_state: () ->
    $(".state_title", @$info).html(@model.get("state_title"))

  load_realtime: () ->
    @client = window.clients.socket
    @client.subscribe "notify:/direct_transactions/#{@model.id}/change_state", (data) =>
      @model.set(
        state: data.state,
        state_title: data.state_title
      )