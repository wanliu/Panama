#describe: 交易聊天

define ["jquery", "backbone", "lib/realtime_client"],
($, Backbone, Realtime) ->

  class TransactionMessage extends Backbone.Model
    set_url: (url) -> @urlRoot = url

    send_message: (data, callback) ->
      @fetch(
        url: "#{@urlRoot}/send_message",
        type: "POST",
        data: {message: data},
        success: callback
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
        @$message.addClass(@selfClassName)
      else
        @$message.addClass(@peopleClassName)

    render: () ->
      @$el

  class SendMessageView extends Backbone.View
    events: {
      "submit form" : "send_message",
      "keyup textarea[name=content]" : 'filter_send_state'
    }
    initialize: (options) ->
      @model = options.model
      @$form = @$(">form")
      @$button = @$form.find("input:submit")
      @$content = @$("textarea[name=content]")

    send_message: () ->
      data = @form_serialize()
      return false if not data["content"]? || data["content"] == ""
      @model.send_message data, (model, data) =>
        @trigger('add_message', data)
        @$content.val('')

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

    _add_msg: (model) ->
      @set_model_url model
      message_view = new MessageView(
        current_user: @current_user,
        model: model,
        template: @template)

      @$messages.append(message_view.render())
      @max_scrollTop()

    reset_message: (collection) ->
      collection.each (model) =>
        @_add_msg(model)

    add_message: (data) ->
      @trans.add(data)

    set_model_url: (model) ->
      model.set_url @remote_url

    realtime_fetch: () ->
      @client = Realtime.client @faye_url
      @client.subscribe @receive_notice_url(), (message) =>
        @add_message(message)

    receive_notice_url: () ->
      "/chat/receive/OrderTransaction_#{@tansaction_id}/#{@current_user.token}"

    max_scrollTop: () ->
      @$message_panel.scrollTop(99999999)

