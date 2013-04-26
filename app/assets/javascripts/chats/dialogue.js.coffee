#describe: 与好友对话

define ["jquery", "backbone"], ($, Backbone) ->

  class Dialogs extends Backbone.Collection
    url : "/dialogues"

  class DialogueView extends Backbone.View
    className: "chat_dialogue_panel"
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)

      @$el.html("<iframe src='/chat_messages/dialogue/#{@friend.id}'></iframe>")
      $("body").append(@$el)

    render: () ->
      @$el

  class DialogueListView extends Backbone.View
    initialize: (options) ->
      _.extend(@, options)
      @dialogs = new Dialogs()
      @dialogs.bind("add", @add_dialogue, @)

    add_dialogue: (model) ->
      d_view = new DialogueView(
        current_user: @current_user,
        friend: model)

    add: (model) ->
      @dialogs.add(model)



  DialogueListView