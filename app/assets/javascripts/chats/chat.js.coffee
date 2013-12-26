#describe: 聊天

root = window || @

class ChatMessage extends Backbone.Model
  urlRoot: "/chat_messages"
  create: (token, callback) ->
    @fetch(
      url: "#{@urlRoot}",
      data: {chat_message: @toJSON(), authenticity_token: token}
      type: "POST",
      success: callback
    )

  read: (friend_id, token, callback = (message) -> ) ->
    @fetch(
      url: "#{@urlRoot}/read/#{friend_id}",
      type: "POST",
      data: {authenticity_token: token}
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
    @title_el.append("<span class='date'>#{@format_date(@model.attributes.created_at.toDate())}</span>")

  format_date: (date) ->
    time_ago = new Date().getTime() - date.getTime() 
    if time_ago > 24*3600*1000
      date.format('MM-dd hh:mm')
    else
      date.format('hh:mm:ss')

  render: () ->
    @$el

class MessageViewList extends Backbone.View
  events: 
    "submit form"        : "send_message"
    "keyup form textarea": "fastKey"

  initialize: (options) ->
    @set_options(options)
    @form = @$("form")
    @content_el = @$(".dialog_content")
    @chat_messages = new ChatMessages()
    @chat_messages.bind("reset", @all_message, @)
    @chat_messages.bind("add", @add_message, @)
    
  fastKey: (event) ->
    event = event ? event:window.event
    @send_message() if event.ctrlKey && event.keyCode == 13

  fetch: () ->
    @chat_messages.fetch(data: {friend_id: @friend.id})

  all_message: (collection) ->
    @content_el.find(">ul>li").remove()
    collection.each (model) =>
      @add_message model

    @max_top()

  add_message: (model) ->
    view = new MessageView(model: model)
    @content_el.find(">ul").append(view.render())

  add: (model) ->
    @chat_messages.add(model)
    @max_top()

  read_notice:(friend_id) ->
    m = @chat_messages.get(model.id)
    m.read()

  set_options: (options) ->
    _.extend(@, options)

  send_message: () ->
    data = @form_data()
    data["receive_user_id"] = @friend.id
    token = data.authenticity_token
    delete(data.authenticity_token)
    model = new ChatMessage(data)
    model.create token, (model, data) =>
      @add model
      @form.find("textarea").val('')
    false

  form_data: () ->
    data = {}
    inputs = @form.serializeArray()
    _.each inputs, (input) =>
      data[input.name] = input.value
    data

  max_top: () ->
    mheight = @content_el.find(">ul").height()
    pheight = @content_el.height()

    @content_el.scrollTop(mheight-pheight)

class root.TransactionChatView extends Backbone.View
  on_class: "online",
  off_class: "offline",
  display_state: true,

  initialize: () ->
    @init_el()
    @form = @$("form")
    @msg_view = new ChatMessage()
    @msgs_view = new MessageViewList(el: @$content_panel)

  init_el: () ->
    @$content_panel = @$(".dialog_content_panel")
    @$head_panel = @$(".dialog_head")
    @state_el = @$head_panel.find(">.state")

  set_options: (options) ->
    _.extend(@, options)
    @msgs_view.set_options(user: @user, friend: @friend)
    @init_state()
    @bind_pm()

  connect_faye_server: () ->
    @client = window.clients
    @client.receive_message @user.token, (message) =>
      model = @msgs_view.add(data.msg)
      if @display_state
        @read_friend_messsage()

    @client.online @friend.id, _.bind(@online, @)

    @client.offline @friend.id, _.bind(@offline, @)

  fetch: () ->
    @msgs_view.fetch()
    @connect_faye_server()

  init_state: () ->
    if @friend.connect_state then @online() else @offline()

  bind_pm: () ->
    pm.bind "chat_dialogue_state", _.bind(@change_display_state, @)

  change_display_state: (state) ->
    @display_state = state
    if @display_state
      @read_friend_messsage()

  online: (friend_id) ->
    @state_el.addClass(@on_class).removeClass(@off_class)

  offline: (friend_id) ->
    @state_el.addClass(@off_class).removeClass(@on_class)

  form_data: () ->
    data = {}
    inputs = @form.serializeArray()
    _.each inputs, (input) =>
      data[input.name] = input.value
    data

  read_friend_messsage: () ->
    data  = @form_data()
    token = data.authenticity_token
    @msg_view.read(@friend.id, token)

