#describe: 与好友对话

define ["jquery", "backbone"], ($, Backbone) ->

  class Dialogs extends Backbone.Collection

  class DialogueView extends Backbone.View
    className: "chat_dialogue_panel"
    initialize: (options) ->
      _.extend(@, options)

    render: () ->

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