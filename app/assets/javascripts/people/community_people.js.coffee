#describe: 个人社区找人
#= require circle
#= require circle_search_user
#= require jquery-ui
root = window || @

class AddedYouUserView extends Backbone.View
  className: "add_you_circle_panel circle_friend"
  notice_el: "<div class='notice_el'>暂时没有...</div>"
    
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)

    @users = new CircleList([], @remote_url)
    @users.bind("add", @add, @)
    @users.bind("reset", @all, @)
    @refresh()

    @user_panel = $("<div />")
    @shop_panel = $("<div />")
    @$el.append("<h5>用户</h5>")
    @$el.append(@user_panel)
    @$el.append("<h5>商店</h5>")
    @$el.append(@shop_panel)

  render: () ->
    @$el

  show: () ->
    @$el.show()

  hide: () ->
    @$el.hide()

  add_shop: (model) ->
    @shop_panel.find(".notice_el").remove()
    @shop_panel.append(@shop_template(model))

  add_user: (model) ->
    @user_panel.find(".notice_el").remove()
    @user_panel.append(@user_template(model))

  all: (collection) ->
    @user_panel.html(@notice_el)
    @shop_panel.html(@notice_el)
    collection.each (model) =>
      if model.get("owner_type") == "User"
        @add_user(model)
      else
        @add_shop(model)

    @bind_drop()

  shop_template: (model) ->
    "<span class='panel-pj added_shop'>
      <img src='#{model.get('icon_url')}' class='img-polaroid'  />
      <span class='name'>#{model.get('name')}</span>
    </span>"

  user_template: (model) ->
    "<span class='panel-pj added_user' data-value-id='#{model.id}'>
      <img src='#{model.get('icon_url')}' class='img-polaroid'  />
      <span class='login'>#{model.get('login')}</span>
    </span>"

  refresh: () ->
    @users.added_users()

  bind_drop: () ->
    @$el.find(".added_user").draggable({
      helper: 'clone',
      opacity: 0.7,
      revert: true,
      revertDuration: 200,
      zIndex: 1
    })


class YouCircleUserView extends Backbone.View
  className: "you_circle_user_panel circle_friend"
  events: {
    "click .remove_you_user" : "delete_related"
  }

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @circle_list = new CircleList([], @remote_url)
    @circle_list.bind("add", @add, @)
    @circle_list.bind("reset", @all, @)
    @circle_list.bind("remove", @remove, @)
    @refresh()

  render: () ->
    @$el

  show: () ->
    @$el.show()

  hide: () ->
    @$el.hide()

  add: (model) ->
    model.set_url(@remote_url)
    @$el.append(@template(model))

  all: (collection) ->
    @$el.html('')
    collection.each (model) =>
      @add(model)

    @bind_drop()
    @filter_notice()

  remove: (model) ->
    @trigger("remove_user", model.id)
    @filter_notice()

  filter_notice: () ->
    if @circle_list.length <= 0
      @$el.html("暂无用户...")

  bind_drop: () ->
    @$(".you_user").draggable({
      helper: 'clone',
      opacity: 0.7,
      revert: true,
      revertDuration: 200,
      zIndex: 1
    })

  template: (model) ->
    "<span class='panel-pj you_user' data-value-id='#{model.id}'>
      <img src='#{model.get('icon_url')}' class='img-polaroid' />
      <span class='login'>#{model.get('login')}</span>
      <a class='close-label remove_you_user' href='javascript:void(0)'></a>
    </span>"

  refresh: () ->
    @circle_list.all_friends()

  delete_related: (event) ->
    span = $(event.currentTarget.parentElement)
    model = @circle_list.get span.attr("data-value-id")
    if confirm("是否确认删除#{model.get('login')}！")
      model.circles_remove_friend (model, data) =>
        @circle_list.remove(model)
        span.remove()


class FriendView extends Backbone.View
  events: {
    "click input.add_you_circle" : "othe_circle_user"
    "click input.you_circle_user" : "you_circle_user"
  }

  initialize: (options) ->
    _.extend(@, options)
    @friend_panel = @$(".circle_user_panel")
    @you_circle_view = new YouCircleUserView( remote_url: @remote_url )
    @add_you_circle_view = new AddedYouUserView( remote_url: @remote_url )
    @search_view = new SearchUserView(input_el: @$(".search_user"))

    @you_circle_view.bind("remove_user", _.bind(@remove_user, @))
    @search_view.bind("switch_show", _.bind(@switch_show, @))
    @search_view.bind("hide_all", _.bind(@hide_all, @))

    @friend_panel.append(@you_circle_view.render())
    @friend_panel.append(@add_you_circle_view.render())
    @friend_panel.append(@search_view.render())

    @added_input = @$("input.add_you_circle")
    @you_input = @$("input.you_circle_user")

  othe_circle_user: (event) ->
    @clear_all_active()
    @added_input.addClass("active")
    @add_you_circle_view.show()
    @add_you_circle_view.refresh()
    @you_circle_view.hide()
    @search_view.hide()

  you_circle_user: () ->
    @clear_all_active()
    @you_input.addClass("active")
    @add_you_circle_view.hide()
    @you_circle_view.show()
    @you_circle_view.refresh()
    @search_view.hide()

  clear_all_active: () ->
    @$(".navs>input:button").removeClass("active")

  switch_show: () ->
    if @added_input.hasClass("active")
      @othe_circle_user()
    else
      @you_circle_user()

  hide_all: () ->
    @you_circle_view.hide()
    @add_you_circle_view.hide()

  remove_user: (user_id) ->
    @trigger("remove_user", user_id)


class CommunityPeopleView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @friend_el = @$(".friends_panel")
    @circle_el = @$(".circle-panel")

    @circle_view_list = new CircleViewList(
      template: @circle_template,
      remote_url: @remote_url,
      el: @circle_el
    )

    @friend_view = new FriendView(
      el: @friend_el,
      remote_url: @remote_url
    )

    @friend_view.bind("remove_user",
      _.bind(@circle_view_list.remove_all_circle_user, @circle_view_list))

    @friend_view.othe_circle_user()

root.CommunityPeopleView = CommunityPeopleView
