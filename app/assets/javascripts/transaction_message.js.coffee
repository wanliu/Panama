#describe: 交易聊天
#= require jquery
#= require backbone
#= require lib/realtime_client
#= require lib/notify

root = window || @

class TransactionMessage extends Backbone.Model
  set_url: (url) -> @urlRoot = url

  send_message: (data, callback, done_call) ->
    token = data.authenticity_token
    delete(data.authenticity_token)
    @fetch(
      url: "#{@urlRoot}/send_message",
      type: "POST",
      data: {message: data, authenticity_token: token},
      success: callback,
      complete: done_call
    )

class TransactionMessageList extends Backbone.Collection
  model: TransactionMessage
  set_url: (url) -> @url = url
  messages: () ->
    @fetch(
      url: "#{@url}/messages"
    )

class MessageView extends Backbone.View
  selfClassName: "self",
  peopleClassName: "people",
  className: "row-msg"

  initialize: (options) ->
    _.extend(@, options)

    @$el = $(@el)
    @$el.html @template.render(@model.toJSON())
    @$message = @$el.find(">.message")

    @load_style()

  load_style: () ->
    if @current_user.id is @model.get("send_user_id")
      @$(".sender").addClass("pull-right")
      @$(".chat-message-body").addClass("on-left")
      @$message.addClass(@selfClassName)
    else
      @$(".sender").addClass("pull-left")
      @$message.addClass(@peopleClassName)

  render: () ->
    @$el

class SendMessageView extends Backbone.View
  events: {
    "submit form" : "send_message",
    "keyup textarea[name=content]" : 'filter_send_state',
    "keydown .textarea-message" : "fastKey"
  }
  initialize: (options) ->
    @model = options.model
    @$form = @$(">form")
    @$button = @$form.find("input:submit")
    @$content = @$("textarea[name=content]")

  fastKey: (event) ->
    event = event ? event:window.event
    if event.ctrlKey && 13 == event.keyCode
       $(".message-form").submit()

  send_message: () ->
    data = @form_serialize()
    return false if not data["content"]? || data["content"] == ""
    return false if @$button.hasClass("disabled")
    @$button.addClass("disabled")
    @model.send_message data,
      (model, data) =>
        @trigger('add_message', data)
        @$content.val('')
        @filter_send_state()
      ,() =>
        @filter_send_state()

    false


  form_serialize: () ->
    ms = @$form.serializeArray()
    data = {}
    _.each ms, (m) =>
      data[m.name] = m.value

    data

  filter_send_state: () ->
    content = @$content.val().trim()
    if content is ""
      @$button.addClass("disabled")
    else
      @$button.removeClass("disabled")


class TransactionMessageView extends Backbone.View

  initialize: (options) ->

    @init_argument(options)
    @init_el()

    @tran = new TransactionMessage()
    @set_model_url @tran

    @trans = new TransactionMessageList()
    @trans.set_url @remote_url
    @trans.bind("add", @_add_msg, @)
    @trans.bind("reset", @reset_message, @)
    @trans.messages()

    @bind_send_message()
    @realtime_fetch()

  bind_send_message: () ->
    @send_msg_view = new SendMessageView(
      model: @tran,
      el: @$(".foot"))

    @send_msg_view.bind("add_message", _.bind(@add_message, @))

  init_el: () ->
    @$message_panel = @$(".message_panel")
    @$messages = @$(".messages")

  init_argument: (options) ->
    @current_user = options.current_user
    @remote_url = options.remote_url
    @template = options.template
    @faye_url = options.faye_url
    @tansaction_id = options.tansaction_id
    @shop = options.shop

  _add_msg: (model) ->
    @set_model_url model
    message_view = new MessageView(
      current_user: @current_user,
      model: model,
      template: @template)

    @$messages.append(message_view.render())
    @max_scrollTop()

  reset_message: (collection) ->
    @$messages.html('')
    `
      for(var i=collection.length-1; i>=0; i--){
        this._add_msg(collection.models[i])
      }
    `
    return

  add_message: (data) ->
    @trans.add(data)

  set_model_url: (model) ->
    model.set_url @remote_url

  realtime_fetch: () ->
    @client = Realtime.client @faye_url

    @client.subscribe @receive_notice_url(), (message) =>
      @notice_bubbing(message)
      @add_message(message)

  receive_notice_url: () ->
    "/chat/receive/OrderTransaction/#{@shop.id}/#{@tansaction_id}_#{@current_user.token}"

  max_scrollTop: () ->
    mheight = @$message_panel.find(">.message-list").height()
    pheight = @$message_panel.height()

    @$message_panel.scrollTop(mheight-pheight)

  notice_bubbing: (message) ->
    pm({
      target : window.parent,
      type : "transaction_chat_notice",
      data : message
    });

root.TransactionMessageView = TransactionMessageView
