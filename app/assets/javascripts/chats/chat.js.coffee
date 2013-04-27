#describe: 聊天
define ["jquery", "backbone", "lib/realtime_client"],
($, Backbone, Realtime) ->
  class ChatMessage extends Backbone.Model
    urlRoot: "/chat_messages"
    read: (callback = (message) -> ) ->
      @fetch(
        url: "#{@urlRoot}/read/#{@id}",
        type: "POST",
        success: callback
      )

  class ChatMessages extends Backbone.Collection
    model: ChatMessage
    url: "/chat_messages"

  class MessageView extends Backbone.View
    tagName: "li",

    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @send_user = @model.get("send_user")

      @init_el()
      @init_data()

    init_data: () ->
      @message_el.append("#{@model.get('content')}")

    init_el: () ->
      @$el.html("<div class='title' /><div class='message' />")
      @title_el = @$(".title")
      @message_el = @$(".message")

      @title_el.append("<img src='#{@send_user.icon_url}' class='img-polaroid' />")
      @title_el.append("<span class='login'>#{@send_user.login}</span>")
      @title_el.append("<span class='date'>#{@format_date()}</span>")

    format_date: () ->
      d = new Date(@model.get('created_at'))
      today = new Date()
      if d.format("yyyy-MM-dd") == today.format("yyyy-MM-dd")
        d.format("h:m")
      else
        d.format("yyyy-MM-dd h:m")

    render: () ->
      @$el

  class MessageViewList extends Backbone.View
    events: {
      "submit form" : "send_message"
    }

    initialize: (options) ->
      @set_options(options)
      @form = @$("form")
      @content_el = @$(".dialog_content")
      @chat_messages = new ChatMessages()
      @chat_messages.bind("reset", @all_message, @)
      @chat_messages.bind("add", @add_message, @)

    fetch: () ->
      @chat_messages.fetch(data: {friend_id: @friend.id})

    all_message: (collection) ->
      collection.each (model) =>
        @add_message model

    add_message: (model) ->
      view = new MessageView(model: model)
      @content_el.find(">ul").append(view.render())
      @content_el.scrollTop(99999999)

    add: (model) ->
      @chat_messages.add(model)

    notice_add:(model) ->
      @add(model)
      m = @chat_messages.get(model.id)
      m.read()

    set_options: (options) ->
      _.extend(@, options)

    send_message: () ->
      data = @form_data()
      data["receive_user_id"] = @friend.id
      model = new ChatMessage(data)
      model.save {}, success: (model, data) =>
        @add model
        @form.find("textarea").val('')
      false

    form_data: () ->
      data = {}
      inputs = @form.serializeArray()
      _.each inputs, (input) =>
        data[input.name] = input.value
      data

  class ChatView extends Backbone.View
    initialize: () ->
      @init_el()
      @msgs_view = new MessageViewList(el: @$content_panel)

    init_el: () ->
      @$content_panel = @$(".dialog_content_panel")

    set_options: (options) ->
      _.extend(@, options)
      @msgs_view.set_options(user: @user, friend: @friend)

    connect_faye_server: () ->
      @realtime = Realtime.client(@faye_url)
      @realtime.receive_message @user.token, (message) =>
        @msgs_view.notice_add(message)

    fetch: () ->
      @msgs_view.fetch()
      @connect_faye_server()