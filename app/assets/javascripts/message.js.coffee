#describe: 交易聊天
#= require lib/notify

root = window || @

class TransactionMessage extends Backbone.Model
  set_url: (url) -> @urlRoot = url

  send_message: (data, callback, done_call,fail) ->
    token = data.authenticity_token
    delete(data.authenticity_token)
    @fetch(
      url: "#{@urlRoot}/send_message",
      type: "POST",
      data: {message: data, authenticity_token: token},
      success: callback,
      complete: done_call
      error: fail
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
  events:
    "submit form"                  : "send_message"
    "keyup textarea[name=content]" : "fastKey"

  initialize: (options) ->
    @model = options.model
    @$form = @$(">form")
    @$button = @$form.find("input:submit")
    @$content = @$("textarea[name=content]")

  fastKey: (event) ->
    @filter_send_state()
    event = event ? event:window.event
    if event.ctrlKey && 13 == event.keyCode
      @send_message()
      @$content.val('')

  send_message: () ->
    data = @form_serialize()
    if not data["content"]? || data["content"] == ""
      return false
    if @$button.hasClass("disabled")
      return false

    @$button.addClass("disabled")
    @model.send_message data,
      (model, data) =>
        @trigger('add_message', data)
        @$content.val('')
        @filter_send_state()
      ,() =>
        @filter_send_state()
      ,() =>
        @$content.val(data["content"])
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
    @realtime_key = options.realtime_key
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
    @client = window.clients.socket
    @client.subscribe @receive_notice_url(), (message) =>
      @notice_bubbing(message)
      @add_message(message)

  receive_notice_url: () ->
    "notify:/#{@shop.token}/#{@realtime_key}/#{@tansaction_id}/chat"

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
