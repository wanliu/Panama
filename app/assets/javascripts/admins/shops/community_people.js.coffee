#describe: 商店社区找人
#= require jquery
#= require backbone
#= require circle
#= require circle_search_user
root = window || @

class YouCircleUserView extends Backbone.View
  events: {
    "click .remove_you_user" : "delete_user"
  }
  className: "you_circle_users circle_friend"

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @user_list = new CircleList([], @remote_url)
    @user_list.bind("reset", @all, @)
    @user_list.bind("add", @add, @)
    @user_list.bind("remove", @remove, @)
    @refresh()

  render: () ->
    @$el

  add: (model) ->
    model.set_url(@remote_url)
    @$el.append( @template(model) )

  all: (collection) ->
    @$el.html('')
    collection.each (model) =>
      @add(model)
    @bind_drop()
    @inspect_notice()

  template: (model) ->
    "<div class='panel-pj you_circle_user' data-value-id='#{model.id}'>
      <div>
        <img src='#{model.get('icon_url')}' class='img-polaroid'  />
      </div>
      <div>
        <lable class='label login'>#{model.get('login')}</label>
        <a href='javascript:void(0)' class='close-label remove_you_user'></a>
      </div>
    </div>"

  show: () ->
    @$el.show()

  hide: () ->
    @$el.hide()

  refresh: () ->
    @user_list.all_friends()
  inspect_notice: () ->
    if @user_list.length <= 0
      @$el.html("暂时没有用户...")

  bind_drop: () ->
    @$el.find(".you_circle_user").draggable({
      helper: 'clone',
      opacity: 0.7,
      revert: true,
      revertDuration: 200,
      zIndex: 1
    })

  delete_user: (event) ->
    span = $(event.currentTarget.parentElement)
    model = @user_list.get(span.attr("data-value-id"))
    if model?
      if confirm("是否确认删除#{model.get('login')}?")
        model.circles_remove_friend (model, data) =>
          @user_list.remove model
          span.remove()

  remove: (model) ->
    @trigger("remove_user", model.id)
    @inspect_notice()

class FollowingUserView extends Backbone.View
  className: "follow_users circle_friend"
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @followers_list = new CircleList([], @remote_url)
    @followers_list.bind("reset", @all, @)
    @followers_list.bind("add", @add, @)
    @refresh()

  all: (collection) ->
    @$el.html('')
    collection.each (model) =>
      @add model

    @bind_drop()
    @inspect_notice()

  add: (model) ->
    model.set_url(@remote_url)
    @$el.append(@template(model))

  render: () ->
    @$el

  show: () ->
    @$el.show()

  hide: () ->
    @$el.hide()

  template: (model) ->
    "<div class='panel-pj follow_user' data-value-id='#{model.id}'>
      <div>
        <img src='#{model.get('icon_url')}' class='img-polaroid'  />
      </div>
      <div>
        <label class='label login'>#{model.get('login')}</label>
      </div>
    </div>"

  refresh: () ->
    @followers_list.followers()

  inspect_notice: () ->
    if @followers_list.length <= 0
      @$el.html('暂时没有关注的用户...')

  bind_drop: () ->
    @$el.find(".follow_user").draggable({
      helper: 'clone',
      opacity: 0.7,
      revert: true,
      revertDuration: 200,
      zIndex: 1
    })

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

    @you_circle_view.bind("remove_user", _.bind(@remove_user, @))
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

  remove_user: (user_id) ->
    @trigger("remove_user", user_id)

class CommunityPeopleView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @circle_panel = @$(".circle-panel")
    @friends_panel = @$(".friends_panel")

    @circle_view_list = new CircleViewList(
      el: @circle_panel,
      remote_url: @remote_url,
      template: @circle_template
    )

    @circle_friend_view = new CircleFriendView({
      el: @friends_panel,
      remote_url: @remote_url
    })
    @circle_friend_view.bind("remove_user",
      _.bind(@circle_view_list.remove_all_circle_user, @circle_view_list))
    @circle_friend_view.show_circle_user()

root.CircleFriendView = CircleFriendView
root.CommunityPeopleView = CommunityPeopleView