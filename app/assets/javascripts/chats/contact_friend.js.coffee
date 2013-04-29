#describe: 最近联系人

define ["jquery", "backbone", "chats/dialogue"],
($, Backbone, DialogueListView) ->

  class ContactFriend extends Backbone.Model
    urlRoot: "/contact_friends"
    join_friend: () ->
      @fetch(
        url: "#{@urlRoot}/join_friend",
      )

  class ContactFriendList extends Backbone.Collection
    model: ContactFriend
    url: "/contact_friends"
    comparator: (a, b) ->
      if a.get("last_contact_date") > b.get("last_contact_date")
        return -1
      if a.get("last_contact_date") < b.get("last_contact_date")
        return 1
      else
        return 0

  class ContactFriendView extends Backbone.View
    tagName: "li",
    notice_class: "notice"
    events:{
      "click " : "show_dialog"
    }

    initialize: (options) ->
      @$el = $(@el)
      @friend = @model.get('friend')
      @init_el()
      @change_state()
      @model.bind("change:unread_count", @change_state, @)

    init_el: () ->
      @$el.html("<a href='javascript:void(0)' class='item' />")
      @avatar_label = $("<img src='#{@friend.icon_url}' class='img-rounded' />")
      @notice_label = $("<div class='state offline'></div>")
      @login_label = $("<span class='login'>#{@friend.login}<span/>")
      @close_label = $("<a href='javascript:void(0)' class='close_label'></a>")

      @$el.find("a.item")
      .append(@avatar_label)
      .append(@notice_label)
      .append(@login_label)
      .append(@close_label)

    render: () ->
      @$el

    show_dialog: () ->
      @trigger("show_dilogue", @friend)

    show_notic: () ->
      @notice_label.addClass(@notice_class)

    hide_notice: () ->
      @notice_label.removeClass(@notice_class)

    change_state: () ->
      if @model.get("unread_count") > 0 then @show_notic() else @hide_notice()

  class ContactFriendViewList extends Backbone.View
    tagName: "ul",

    initialize: (options) ->
      _.extend(@, options)

      @$el = $(@el)
      @friends = new ContactFriendList()
      @friends.bind("reset", @all_contact_friend, @)
      @friends.bind("add", @add_contact_friend, @)
      @friends.bind("sort", @all_contact_friend, @)
      @friends.fetch()

      @dilogue_views = new DialogueListView({
        current_user: @current_user
      })

    all_contact_friend: (collection) ->
      @$el.html('')
      collection.each (model) =>
        @add_contact_friend(model)

    add_contact_friend: (model) ->
      cf_view = new ContactFriendView(model: model)
      cf_view.bind("show_dilogue", _.bind(@show_dilogue, @))
      @$el.append(cf_view.render())

    add: (model) ->
      friend = @find_friend(model.friend_id)
      if friend?
        friend.set("last_contact_date", model.last_contact_date)
      else
        @friends.add(model)

      @sort_friend()

    show_dilogue: (model) ->
      @dilogue_views.add(model)

    receive_notic: (friend_id) ->
      m = @find_friend(friend_id)
      m.set("unread_count", 1 + parseInt(m.get("unread_count"))) if m?

    read_notice: (friend_id) ->
      m = @find_friend(friend_id)
      m.set("unread_count", 0) if m?

    find_friend: (friend_id) ->
      for model in @friends.models
        if model.get("friend_id").toString() is friend_id.toString()
          return model

    sort_friend: () ->
      @friends.sort()

    render: () ->
      @$el