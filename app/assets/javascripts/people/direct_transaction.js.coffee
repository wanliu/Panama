root = (window || @)

class Direct extends Backbone.Model

class root.DirectTransactionView extends Backbone.View
  events: {
    "click .chat_wrapper .message-toggle": "toggle_message"
    "click .direct-info .completed"        : "completed"
  }

  initialize: () ->
    @$info = @$(".direct-info")
    @login = @options.login
    @$el = $(@el)
    @$message = @$(".chat_wrapper")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")
    @model = new Direct(
      state: @$el.attr("state-name"),
      id: @$el.attr("data-value-id"))
    @urlRoot = "/people/#{@login}/direct_transactions/#{@model.id}"

    @model.bind("change:state", @change_state, @)
    @load_realtime()
    # @load_style()
    @toggle_message()

  load_style: () ->
    setTimeout () =>
      padding = parseInt(@$message.css("padding-bottom")) + parseInt(@$message.css("padding-top"))
      @$messages.height(@$info.outerHeight() - @$toolbar.outerHeight() - padding)
    , 60

  toggle_message: () ->
    # @$messages.slideToggle()
    @generateToken () =>
      @newAttachChat()

  newAttachChat: () ->
    unless @chat_model?
      @chat_model = new ChatModel({
        type: 3,
        name: @$el.attr('data-token'),
        group: @$el.data('number')
      })
      @chat_model = ChatManager.getInstance().addChatIcon(@chat_model)
    @chat_model.icon_view.toggleChat()

  generateToken: (handle) ->
    return handle.call(@) unless _.isEmpty(@$el.attr('data-token'))
    $.ajax(
      type: 'POST',
      dataType: 'json',
      url: "#{@urlRoot}/generate_token",
      success: (data, xhr, res) =>
        @$el.attr('data-token', data.token)
        handle.call(@)
      error: () =>
        pnotify(type: 'error', text: '获取聊天token失败')
    )

  completed: () ->
    $.ajax(
      url: "#{@urlRoot}/completed",
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