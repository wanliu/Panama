#describe: 与好友对话

define ["jquery", "backbone"], ($, Backbone) ->

  class Dialogs extends Backbone.Collection
    url : "/dialogues"

  class DialogueView extends Backbone.View
    className: "chat_dialogue_panel"
    position_left: 5
    events: {
      "click .close_label" : "change_hide_state"
    }
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)

      @friend.bind("change:state", @change_state, @)
      @friend.set("state", true)
      @$el.html("<iframe src='/chat_messages/dialogue/#{@friend.id}'></iframe>")
      @$el.append("<a class='close_label' href='javascript:void(0)'></a>")
      @friend.bind("set_position", _.bind(@set_position, @))

      $("body").append(@$el)

    render: () ->
      @$el

    change_state: () ->
      if @friend.get("state") then @show() else @hide()
      @friend.trigger("sort_dialogs")

    change_hide_state: () ->
      @friend.set("state", false)

    set_position: (number) ->
      @$el.css(left: number*305 + @position_left)

    show: () ->
      @$el.show()

    hide: () ->
      @$el.hide()

  class DialogueListView extends Backbone.View
    initialize: (options) ->
      _.extend(@, options)
      @dialogs = new Dialogs()
      @dialogs.bind("add", @add_dialogue, @)

    add_dialogue: (model) ->
      model.bind("sort_dialogs", @sort_dialogs, @)
      dview = new DialogueView(
        current_user: @current_user,
        friend: model
      )

    add: (model) ->
      m = @dialogs.get(model.id)
      if m?
        m.set("state", true)
      else
        @dialogs.add(model)

    show_dialog_number: () ->
      _.inject(@dialogs.models, (memo, m) ->
        memo += 1 if m.get("state")
        return memo
      , -1)

    find_dialog_index: (model) ->
      _.indexOf(@dialogs.models, model)

    sort_dialogs: () ->
      @dialogs.each (m) =>
        if m.get("state")
          m.trigger("set_position", @find_dialog_index(m))

  DialogueListView