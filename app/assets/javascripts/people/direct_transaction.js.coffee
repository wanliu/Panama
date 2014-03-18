root = (window || @)

class Direct extends Backbone.Model

class root.DirectTransactionView extends Backbone.View
  events:
    "click .wrap_event .completed" : "completed"

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
    $(window).bind("resizeOrderChat", _.bind(@setChatPanel, @))
    
    @load_realtime()
    @generateChat()

  messageWrap: () ->
    @$el.parents('.wrapper-box').find('.message_wrap')  

  setChatPanel: () ->
    $order_row = @$el.parents('.wrapper-box')
    $chat_foot = @messageWrap().find(".foot")
    $chat_body = @messageWrap().find(".body")
    height = $order_row.outerHeight() - $chat_foot.outerHeight()
    $chat_body.height(height) if height > 100

  generateChat: () ->
    @generateToken () =>
      if _.isEmpty(@$el.attr('data-token'))
        @messageWrap().html(
          '请求聊天超时，点这里重新<a class="generate-chat" href="javascript: void(0)">请求聊天</a>')
        @messageWrap().find('.generate-chat').bind 'click', () => @generateChat()
      else
        @newAttachChat()

  newAttachChat: () ->
    unless @chat_model?
      @chat_model = new ChatModel({
        type: 3,
        token: @$el.attr('data-token'),
        title: @$el.parents('.wrapper-box').attr('data-group')
      })
      @chat_model = ChatManager.getInstance().addChatIcon(@chat_model)
    @chat_model.icon_view.toggleChat()

  generateToken: (handle) ->
    @messageWrap().html('<img src="/assets/loading_max.gif">')
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
    @setChatPanel()
    @$(".wrap_event .state_title").html(@model.get("state_title"))

  load_realtime: () ->
    @client = window.clients.socket
    @client.subscribe "notify:/direct_transactions/#{@model.id}/change_state", (data) =>
      @model.set(
        state: data.state,
        state_title: data.state_title
      )