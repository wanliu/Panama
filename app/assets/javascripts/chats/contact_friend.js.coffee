#describe: 最近联系人

define ["jquery", "backbone"], ($, Backbone) ->

  class ContactFriend extends Backbone.Model
    urlRoot: "/contact_friends"

  class ContactFriendList extends Backbone.Collection
    model: ContactFriend
    url: "/contact_friends"

  class ContactFriendView extends Backbone.View
    tagName: "li",

    initialize: (options) ->
      @$el = $(@el)
      @login_label = "<span>#{@model.get('friend').login}<span/>"
      @avatar_label = "<img src='#{@model.get("friend").icon_url}' class='img-rounded' />"
      @$el.append(@avatar_label).append(@login_label)

    render: () ->
      @$el

  class ContactFriendViewList extends Backbone.View
    tagName: "ul",

    initialize: (options) ->
      _.extend(@, options)

      @$el = $(@el)
      @contact_friends = new ContactFriendList()
      @contact_friends.bind("reset", @all_contact_friend, @)
      @contact_friends.bind("add", @add_contact_friend, @)
      @contact_friends.fetch()

    all_contact_friend: (collection) ->
      collection.each (model) =>
        @add_contact_friend(model)

    add_contact_friend: (model) ->
      cf_view = new ContactFriendView(model: model)
      @$el.append(cf_view)

    add: (model) ->
      @contact_friends.add(model)

    render: () ->
      @$el