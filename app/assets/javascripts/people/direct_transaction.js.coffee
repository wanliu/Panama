root = (window || @)

class Direct extends Backbone.Model

class root.DirectTransactionView extends Backbone.View
  events:
    "click .wrap_event .completed" : "completed"
    "click .address-add>button"    : "addAddress"
    "click .item-detail"           : "toggleItemDetail"
    "click .chzn-results>li"       : "hideAddress"

  initialize: () ->
    @init_elem()
    @hideAddress()
    @model = new Direct(
      state: @$el.attr("state-name"),
      id: @$el.attr("data-value-id"))
    @urlRoot = "/people/#{@login}/direct_transactions/#{@model.id}"

    @model.bind("change:state", @change_state, @)
    @model.bind("change:address", @change_address, @)
    $(window).bind("resizeOrderChat", _.bind(@setChatPanel, @))
    
    @load_realtime()
    @generateChat()

  init_elem: () =>
    @$info = @$(".direct-info")
    @login = @options.login
    @$el = $(@el)
    @$message = @$(".chat_wrapper")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")
    @group = @$el.parents('.wrapper-box').attr('data-group')

  addAddress: (event) ->
    @$(".address-panel").slideToggle()
    @$el.find("abbr:first").trigger("mouseup")
    false

  toggleItemDetail: (event) ->
    @$(".item-details").slideToggle()
    false

  hideAddress: () ->
    @$(".address-panel").slideUp()

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
        title: @group
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
        if data && !_.isEmpty(data.token)
          @$el.attr('data-token', data.token)
          chat = Caramal.MessageManager.nameOfChannel(@group, 3)
          chat.token = data.token
          chat.open()
        handle.call(@)
      error: () =>
        console.error('请求聊天失败')
    )

  completed: () ->
    $.ajax(
      type: 'POST',
      url: "#{@urlRoot}/completed",
      data: {data: @$(".address-form > form").serializeHash()},
      success: (data) =>
        @model.set(
          address: data.address,
          state: data.state_name,
          state_title: data.state_title
        )
    )

  change_address: () ->
    @setChatPanel()
    @$(".transaction-address").html("<p><strong>收货地址：</strong>#{ @model.get('address')}</p>")

  change_state: () ->
    @setChatPanel()
    @$(".wrap_event .state_title").html(@model.get("state_title"))

  load_realtime: () ->
    @client = window.clients.socket
    @client.subscribe "notify:/direct_transactions/#{@model.id}/change_state", (data) =>
      @model.set(
        address: data.address,
        state: data.state,
        state_title: data.state_title
      )

