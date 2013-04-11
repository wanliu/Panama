#describe: 商店社区找人
define ["jquery", "backbone", "circle", "circle_search_user"],
 ($, Backbone, exports, SearchUserView) =>
  class YouCircleUserView extends Backbone.View
    className: "you_circle_user circle_friend"
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @user_list = new exports.CircleList([], @remote_url)
      @user_list.bind("reset", @all, @)
      @user_list.bind("add", @add, @)
      @refresh()

    render: () ->
      @$el

    add: (model) ->
      @$el.append( @template(model) )

    all: (collection) ->
      @$el.html('')
      collection.each (model) =>
        @add(model)

    template: (model) ->
      "<span class='panel-pj you_circle_user' data-value-id='#{model.id}'>
        <img src='#{model.get('icon_url')}' class='img-polaroid'  />
        <span class='login'>#{model.get('login')}</span>
      </span>"

    show: () ->
      @$el.show()

    hide: () ->
      @$el.hide()

    refresh: () ->
      @user_list.all_friends()

  class FollowingUserView extends Backbone.View
    className: "follow_user circle_friend"
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @followers_list = new exports.CircleList([], @remote_url)
      @followers_list.bind("reset", @all, @)
      @followers_list.bind("add", @add, @)
      @refresh()

    all: (collection) ->
      @$el.html('')
      collection.each (model) =>
        @add model

    add: (model) ->
      @$el.append(@template(model))

    render: () ->
      @$el

    show: () ->
      @$el.show()

    hide: () ->
      @$el.hide()

    template: (model) ->
      "<span class='panel-pj follow_user' data-value-id='#{model.id}'>
        <img src='#{model.get('icon_url')}' class='img-polaroid'  />
        <span class='login'>#{model.get('login')}</span>
      </span>"

    refresh: () ->
      @followers_list.followers()

  class CircleFriendView extends Backbone.View
    events: {
      "click .you_circle_user" : "show_circle_user"
      "click .follow_user" : "show_follow_user"
    }

    initialize: (options) ->
      _.extend(@, options)
      @circle_user_panel = @$(".circle_user_panel")

      @search_user_view = new SearchUserView( input_el: @$('.search_user') )
      @follow_view = new FollowingUserView(remote_url: @remote_url)
      @you_circle_view = new YouCircleUserView(remote_url: @remote_url)

      @search_user_view.bind("switch_show", _.bind(@switch_show, @))
      @search_user_view.bind("hide_all", _.bind(@hide_all, @))

      @circle_user_panel.append(@search_user_view.render())
      @circle_user_panel.append(@follow_view.render())
      @circle_user_panel.append(@you_circle_view.render())

    show_circle_user: () ->
      @clear_active()
      @$(".you_circle_user").addClass("active")
      @follow_view.hide()
      @search_user_view.hide()
      @you_circle_view.show()
      @you_circle_view.refresh()

    show_follow_user: () ->
      @clear_active()
      @$(".follow_user").addClass("active")
      @you_circle_view.hide()
      @search_user_view.hide()
      @follow_view.show()
      @follow_view.refresh()

    clear_active: () ->
      @$(".navs>input:button").removeClass("active")

    switch_show: () ->
      @$(".navs>input:button.active").click()

    hide_all: () ->
      @you_circle_view.hide()
      @follow_view.hide()

    render: () ->

  class CommunityPeopleView extends Backbone.View

    initialize: (options) ->
      _.extend(@, options)
      @circle_panel = @$(".circle-panel")
      @friends_panel = @$(".friends_panel")

      @circle_view_list = new exports.CircleViewList(
        el: @circle_panel,
        remote_url: @remote_url,
        template: @circle_template
      )

      @circle_friend_view = new CircleFriendView({
        el: @friends_panel,
        remote_url: @remote_url
      })
      @circle_friend_view.show_circle_user()

