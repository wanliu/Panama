root = (window || @)

class root.ShopDirectTransactionView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @init_elem()

    @model = new Backbone.Model(
      address: "",
      state: @$el.attr("state-name"),
      id: @$el.attr("data-value-id"))

    @model.bind("change:state", @change_state, @)
    @model.bind("change:address", @change_address, @)
    @load_realtime()
    $(window).bind("resizeOrderChat", _.bind(@load_style, @))
    # @load_style()
    @generateChat()

  init_elem: () =>
    @$el = $(@el)
    @$info = @$(".direct-info")
    @$message = @$(".chat_wrapper")
    @$iframe = @$message.find("iframe")
    @$messages = @$message.find(".messages")
    @$toolbar = @$message.find(".toolbar")
    @group = @$el.parents('.wrapper-box').attr('data-group')

  load_style: () ->
    padding = parseInt(@$message.css("padding-bottom")) + parseInt(@$message.css("padding-top"))
    @$messages.height( @$info.outerHeight() - @$toolbar.outerHeight() - padding)

  messageWrap: () ->
    @$el.parents('.wrapper-box').find('.message_wrap')

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
    @urlRoot = "/shops/#{@shop.name}/admins/direct_transactions/#{@model.id}"
    $.ajax(
      type: 'POST',
      dataType: 'json',
      url: "#{@urlRoot}/generate_token",
      success: (data, xhr, res) =>
        @$el.attr('data-token', data.token)
        g = Caramal.MessageManager.nameOfChannel(@group, 3)
        g.token = data.token
        handle.call(@)
      error: () =>
        console.error('请求聊天失败')
    )

  change_state: () ->
    @$(".wrap_event .state_title").html(@model.get("state_title"))

  change_address: () ->
    @$(".transaction_address > p").html(@model.get("address"))

  load_realtime: () ->
    @client = window.clients.socket
    @client.subscribe "notify:/#{@shop.token}/direct_transactions/#{@model.id}/change_state", (data) =>
      @model.set(
        address: data.address,
        state: data.state,
        state_title: data.state_title
      )
