#describe: 最近联系人
#= require chats/dialogue

root = window || @

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
  online_class: "online"
  offline_class: "offline"

  events:{
    "click " : "show_dialog"
  }

  initialize: (options) ->
    @$el = $(@el)
    @friend = @model.get('friend')
    @init_el()

    @model.bind("change:state", @change_state, @)
    @model.bind("change:unread_count", @change_message, @)
    @change_state()
    @change_message()

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
    @clear_all_state()
    @notice_label.addClass(@notice_class)

  hide_notice: () ->
    @notice_label.removeClass(@notice_class)
    @change_state()

  online: () ->
    if @message_state()
      @clear_all_state()
      @notice_label.addClass @online_class

  offline: () ->
    if @message_state()
      @clear_all_state()
      @notice_label.addClass @offline_class

  message_state: () ->
    @model.get("unread_count") <= 0

  change_message: () ->
    if @model.get("unread_count") > 0 then @show_notic() else @hide_notice()

  change_state: () ->
    if @model.get("state") then @online() else @offline()

  clear_all_state: () ->
    @notice_label.removeClass @notice_class
    @notice_label.removeClass @offline_class
    @notice_label.removeClass @online_class

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

    @dilogue_views = new DialogueListView(
      current_user: @current_user
    )

    # @client = Realtime.client(@faye_url)
    @client = window.clients

  all_contact_friend: (collection) ->
    @$el.html('')
    collection.each (model) =>
      @add_contact_friend(model)

  add_contact_friend: (model) ->
    cf_view = new ContactFriendView(model: model)
    cf_view.bind("show_dilogue", _.bind(@show_dilogue, @))

    @$el.append(cf_view.render())
    friend_id = model.get("friend_id")
    @client.online(friend_id, _.bind(@online_friend, @))
    @client.offline(friend_id, _.bind(@offline_friend, @))

  add: (model) ->
    friend = @find_friend(model.friend_id)
    if friend?
      friend.set("last_contact_date", model.last_contact_date)
    else
      @friends.add(model)

    @sort_friend()

  offline_friend: (friend_id) ->
    model = @friends.where(friend_id: parseInt(friend_id))[0]
    model.set("state", false)  if model?

  online_friend: (friend_id) ->
    model = @friends.where(friend_id: parseInt(friend_id))[0]
    model.set("state", true)  if model?

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

root.ContactFriendViewList = ContactFriendViewList
#root.ContactFriendView = ContactFriendView
#root.ContactFriendList = ContactFriendList
#root.ContactFriend = ContactFriend