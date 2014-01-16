root = (window || @)

class root.ShopDirectTransactionView extends Backbone.View
  events: {
    "click .chat_wrapper .message-toggle" : "toggle_message"
  }

  initialize: (options) ->
    _.extend(@, options)
    @init_elem()

    @model = new Backbone.Model(
      state: @$el.attr("state-name"),
      id: @$el.attr("data-value-id"))

    @model.bind("change:state", @change_state, @)
    @load_realtime()
    # @load_style()
    @toggle_message()

  init_elem: () =>
    @$el = $(@el)
    @$info = @$(".direct-info")
    @$message = @$(".chat_wrapper")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")

  load_style: () ->
    setTimeout () =>
      padding = parseInt(@$message.css("padding-bottom")) + parseInt(@$message.css("padding-top"))
      @$messages.height( @$info.outerHeight() - @$toolbar.outerHeight() - padding)
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
        group: @$el.parents('.wrapper-box').attr('data-group')
      })
      @chat_model = ChatManager.getInstance().addChatIcon(@chat_model)
    @chat_model.icon_view.toggleChat()

  generateToken: (handle) ->
    return handle.call(@) unless _.isEmpty(@$el.attr('data-token'))
    @urlRoot = "/shops/#{@shop.name}/admins/direct_transactions/#{@model.id}"
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

  change_state: () ->
    @$(".wrap_event .state_title").html(@model.get("state_title"))

  load_realtime: () ->
    @client = window.clients.socket

    @client.subscribe "notify:/#{@shop.token}/direct_transactions/#{@model.id}/change_state", (data) =>
      @model.set(
        state: data.state,
        state_title: data.state_title
      )
