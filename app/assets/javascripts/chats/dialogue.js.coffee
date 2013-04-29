#describe: 与好友对话

define ["jquery", "backbone"], ($, Backbone) ->

  class Dialogs extends Backbone.Collection
    url : "/dialogues"
    comparator: (a, b) ->
      if a.get("dialog_index") < b.get("dialog_index")
        -1
      else if a.get("dialog_index") > b.get("dialog_index")
        1
      else
        0

  class DialogueView extends Backbone.View
    sort_dialogs: () ->
    className: "chat_dialogue_panel"

    events: {
      "click .close_label" : "change_hide_state"
    }
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)

      @friend.bind("change:state", @change_state, @)
      @friend.bind("change:dialog_index", @set_position, @)
      @$el.html("<iframe src='/chat_messages/dialogue/#{@friend.id}'></iframe>")
      @$el.append("<a class='close_label' href='javascript:void(0)'></a>")

      @set_position()
      @show()

      $("body").append(@$el)

    render: () ->
      @$el

    change_state: () ->
      @sort_dialogs()
      if @friend.get("state") then @show() else @hide()

    change_hide_state: () ->
      @friend.set("state", false)

    set_position: () ->
      position = @friend.get("dialog_index")*@dialogWith + @marginLeft
      @$el.css(left: position)

    show: () ->
      @$el.show()

    hide: () ->
      @$el.hide()

  class DialogueListView extends Backbone.View
    marginLeft: 5,
    navRight: 300,   #工具width
    dialogWith: 305, #框width

    initialize: (options) ->
      _.extend(@, options)
      @dialogs = new Dialogs()
      @dialogs.bind("add", @add_dialogue, @)
      @dialogs.bind("sort", @sort_dialogs, @)

      $(window).resize () =>
        @calculation_width()

    add_dialogue: (model) ->
      dview = new DialogueView(
        current_user: @current_user,
        friend: model,
        marginLeft: @marginLeft,
        dialogWith: @dialogWith
      )

      dview.sort_dialogs = _.bind(@sort_dialog_index, @)
      @calculation_width()

    add: (model) ->
      m = @dialogs.get(model.id)
      if m? && !m.get("state")
        #显示框的位置下标
        m.set("dialog_index", @show_dialog_number())
        #显示状态
        m.set("state", true)
      else
        @dialogs.add _.extend({}, model, {
          dialog_index: @show_dialog_number(),
          state: true
        })

    show_dialog_number: () ->
      _.inject(@dialogs.models, (memo, m) ->
        memo += 1 if m.get("state")
        return memo
      , 0)

    calculation_width: () ->
      if (@show_dialog_number() * (@dialogWith + @marginLeft))  > ($("body").width() - @navRight)
        @hide_first_show()

    hide_first_show: () ->
      model = @dialogs.where({"state": true})[0]
      model.set("state", false) if model?

    sort_dialog_index: () ->
      @dialogs.sort()
      @calculation_width()

    sort_dialogs: () ->
      number = -1
      @dialogs.each (m) =>
        if m.get("state")
          number += 1
          m.set("dialog_index", number)

  DialogueListView