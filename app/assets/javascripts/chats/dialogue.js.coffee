#describe: 与好友对话

define ["jquery", "backbone"], ($, Backbone) ->

  class Messages extends Backbone.Collection
    url : "/chat_messages"

    fetch_friend: (friend_id) ->
      @fetch({
        url: "#{@url}/#{friend_id}"
      })

  class Dialogs extends Backbone.Collection
    url : "/dialogues"

  class MessageView extends Backbone.View
    tagName: "li"
    initialize: () ->


  class DialogueView extends Backbone.View
    className: "chat_dialogue_panel"
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @messages = new Messages()
      @messages.bind("reset", @all_message, @)
      #@messages.fetch_friend(@friend.id)
      @$el.html("<iframe src='/chat_messages/dialogue/#{@friend.id}'></iframe>")
      $("body").append(@$el)

    all_message: (collection) ->
      collection.each (model) =>
        @add_message(model)

    add_message: (model) ->
      message_view = new MessageView()

    render: () ->
      @$el

  class DialogueListView extends Backbone.View
    initialize: (options) ->
      _.extend(@, options)
      @dialogs = new Dialogs()
      @dialogs.bind("add", @add_dialogue, @)

    render: () ->

    add_dialogue: (model) ->
      d_view = new DialogueView(
        current_user: @current_user,
        friend: model)

    add: (model) ->
      @dialogs.add(model)



  DialogueListView