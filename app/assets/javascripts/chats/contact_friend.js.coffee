#describe: 最近联系人

define ["jquery", "backbone", "chats/dialogue"],
($, Backbone, DialogueListView) ->

  class ContactFriend extends Backbone.Model
    urlRoot: "/contact_friends"

  class ContactFriendList extends Backbone.Collection
    model: ContactFriend
    url: "/contact_friends"

  class ContactFriendView extends Backbone.View
    tagName: "li",
    events:{
      "click .close_label" : "remove_friend",
      "click " : "show_dialog"
    }

    initialize: (options) ->
      @$el = $(@el)
      @$el.html("<a href='javascript:void(0)' class='item' />")

      @friend = @model.get('friend')
      @login_label = "<span class='login'>#{@friend.login}<span/>"
      @avatar_label = "<img src='#{@friend.icon_url}' class='img-rounded' />"
      @close_label = "<a href='javascript:void(0)' class='close_label'></a>"
      @$el.find("a.item").append(@avatar_label).append(@login_label).append(@close_label)

    render: () ->
      @$el

    remove_friend: () ->
      console.log("gfd")

    show_dialog: () ->
      @trigger("show_dilogue", @friend)

  class ContactFriendViewList extends Backbone.View
    tagName: "ul",

    initialize: (options) ->
      _.extend(@, options)

      @$el = $(@el)
      @contact_friends = new ContactFriendList()
      @contact_friends.bind("reset", @all_contact_friend, @)
      @contact_friends.bind("add", @add_contact_friend, @)
      @contact_friends.fetch()

      @dilogue_views = new DialogueListView({
        current_user: @current_user
      })

    all_contact_friend: (collection) ->
      collection.each (model) =>
        @add_contact_friend(model)

    add_contact_friend: (model) ->
      cf_view = new ContactFriendView(model: model)
      cf_view.bind("show_dilogue", _.bind(@show_dilogue, @))
      @$el.append(cf_view.render())

    add: (model) ->
      @contact_friends.add(model)

    show_dilogue: (model) ->
      @dilogue_views.add(model)

    render: () ->
      @$el