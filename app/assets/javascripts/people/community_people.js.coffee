#describe: 社区找人
define ["jquery", "backbone", "jquery-ui", "twitter/bootstrap/modal"], ($, Backbone) ->

  class Circle extends Backbone.Model
    set_url: (login) ->
      @urlRoot = "/people/#{login}/circles"

    constructor: (attr, login) ->
      @set_url(login)
      super attr

    join_friend: (user_id, scallback, ecallback) ->
      @fetch({
        url: "#{@urlRoot}/#{@id}/join_friend/#{user_id}",
        type: "POST",
        success: scallback,
        error: ecallback
      })

    remove_friend: (user_id, callback) ->
      @fetch({
        url: "#{@urlRoot}/#{@id}/remove_friend/#{user_id}",
        type: "delete",
        success: callback
      })

    circles_remove_friend: (callback) ->
      @fetch(
        url: "#{@urlRoot}/circles_remove_friend/#{@id}"
        type: "delete",
        success: callback
      )

  class CircleList extends Backbone.Collection
    model: Circle
    set_url: (login) ->
      @url = "/people/#{login}/circles"

    constructor: (models, login) ->
      @set_url(login)
      super models

    added_users: () ->
      @fetch(
        url: "#{@url}/addedyou"
      )

    all_friends: () ->
      @fetch(
        url: "#{@url}/all_friends"
      )

    friends: (circle_id) ->
      @fetch({
          url: "#{@url}/friends",
          data: {circle_id: circle_id}
        })

  class UserList extends Backbone.Collection
    url: "/search/users"

  class CircleUser extends Backbone.View
    tagName: "span"
    className: "label user"
    events: {
      "click .remove_user" : "cloes_user"
    }
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @$el.html(@model.get('login'))
      @$el.append("<a class='close-label remove_user' href='javascript:void(0)'></a>")
      @model.bind("remove", @remove, @)

    render: () ->
      @$el

    cloes_user: () ->
      if confirm("是否确认删除#{@model.get('login')}?")
        @circle.remove_friend @model.id, (model, data) =>
          @trigger("find_remove", @model.id)

    remove: () ->
      @$el.remove()

  class CircleUserList extends Backbone.View
    notice_el: "<div class='notice'>暂时没有好友!</div>"
    initialize: (options) ->
      _.extend(@, options)
      @user_list = new CircleList([], @login)
      @user_list.bind("add", @add_one, @)
      @user_list.bind("reset", @all_user, @)
      @user_list.friends(@model.id)

    render: () ->
      @el

    all_user: (collection) ->
      collection.each (model) =>
        @add_one(model)

      @filter_msg()

    add_one: (model) ->
      @$(".notice").remove()
      @circle_view = new CircleUser(
        circle: @model,
        model: model )
      @circle_view.bind("find_remove", _.bind(@find_remove, @))
      @el.append(@circle_view.render())

    find_remove: (id) ->
      model = @user_list.get(id)
      if model?
        model.trigger("remove")
        @user_list.remove(model)
        @filter_msg()

    filter_msg: () ->
      if @user_list.length <= 0
        @el.html(@notice_el)

  class CircleView extends Backbone.View
    className: "alert alert-info circle"
    events: {
      "click .remove_circle" : "delete"
    }
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @$el.html(@template.render(@model.toJSON()))

      @circle_user_list = new CircleUserList(
        model: @model,
        el: @$(".user-list"),
        login: @login
      )

      @$el.droppable(
        drop: _.bind(@join_friend, @)
      )

      @model.bind("remove_user", _.bind(@remove_user, @))

    render: () ->
      @$el

    delete: () ->
      if confirm("是否确认删除#{@model.get('name')}圈子?")
        @model.destroy()
        @$el.remove()

    join_friend: (event, ui) ->
      user_id = $(ui.helper).attr("data-value-id")
      circle = new Circle({id: @model.id}, @login)
      circle.join_friend user_id,
        (model, data) =>
          @circle_user_list.user_list.add(data)
        (model, data, t) =>
          m = JSON.parse(data.responseText)
          alert(m.message)

    remove_user: (user_id) ->
      @circle_user_list.find_remove(user_id)

  class CircleViewList extends Backbone.View
    events: {
      "click .add-circle" : "show_add_circle"
      "click .save-circle" : "create_circle"
      "keypress input.circle_name" : "key_up"
    }
    initialize: (options) ->
      _.extend(@, options)

      @circles = new CircleList([], @login)
      @circles.bind("add", @add_circle, @)
      @circles.bind("reset", @all_circle, @)
      @circles.fetch()

      @circle_el = @$(".circle-list")
      @add_panel = @$(".add_circle_panel")

    render: () ->

    all_circle: (collection) ->
      collection.each (model) =>
        @add_circle(model)

    add_circle: (model) ->
      model.set_url(@login)
      circle_view = new CircleView({
        model: model,
        template: @template,
        login: @login
      })

      @circle_el.append(circle_view.render())

    show_add_circle: () ->
      @add_panel.modal("show")

    create_circle: () ->
      val = @$("input.circle_name").val().trim()
      if val is ""
        @$(".error").html("名称不能为空！")
        return

      @circle = new Circle({name: val}, @login)
      @circle.save({},
        success: (model, data) =>
          @circles.add(data)
          @$("input.circle_name").val('')

        error: (model, data) =>
          data = JSON.parse(data.responseText)
          _.each data, (d) =>
            @$(".error").append(d)
      )

    key_up: (e) ->
      @create_circle() if e.keyCode == 13

    remove_all_circle_user: (user_id) ->
      @circles.each (model) =>
        model.trigger("remove_user", user_id)

  class AddedYouUserView extends Backbone.View
    className: "add_you_circle_panel circle_friend"
    notice_el: "<div class='notice_el'>暂时没有...</div>"
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)

      @users = new CircleList([], @login)
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
      @circle_list = new CircleList([], @login)
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
      model.set_url(@login)
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
      @$el.find(".you_user").draggable({
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

  class SearchUserView extends Backbone.View
    className: "search_user circle_friend"

    initialize: (options) ->
      _.extend(@, options)
      @users = new UserList()
      @users.bind("reset", @all, @)
      @users.bind("add", @add, @)
      @input = @input_el.find("input:text")
      @$el = $(@el)

      @input_el.on "keyup", "input:text", () =>
        clearTimeout(@time_id) if @time_id?
        @time_id = setTimeout(_.bind(@search_user, @), 300)

      @input_el.on "focus", "input:text", () =>
        @show() if @input.val().trim() isnt ""

    search_user: () ->
      query = @input.val().trim()
      return if query is @query_val
      if query == ""
        @hide_to_switch()
      else
        @query_val = query
        @$el.html("正在加载中...")
        @users.fetch(data: {q: query})

    all: (collection) ->
      @show()
      @$el.html("")
      collection.each (model) =>
        @add(model)

      if collection.length<=0
        @$el.html("未找到匹配的人...")
      else
        @bind_drop()

    add: (model) ->
      @$el.append("<span class='panel-pj user' data-value-id='#{model.id}'>
        <img src='#{model.get("icon_url")}' class='img-polaroid' />
        #{model.get("login")}</span>")

    hide_to_switch: () ->
      @hide()
      @trigger("switch_show")

    hide: () ->
      @$el.hide()

    show: () ->
      @trigger("hide_all")
      @$el.show()

    render: () ->
      @$el

    bind_drop: () ->
      @$el.find(".user").draggable({
        helper: 'clone',
        opacity: 0.7,
        revert: true,
        revertDuration: 200,
        zIndex: 1
      })

  class FriendView extends Backbone.View
    events: {
      "click input.add_you_circle" : "othe_circle_user"
      "click input.you_circle_user" : "you_circle_user"
    }

    initialize: (options) ->
      _.extend(@, options)
      @friend_panel = @$(".circle_user_panel")
      @you_circle_view = new YouCircleUserView( login: @login )
      @add_you_circle_view = new AddedYouUserView( login: @login )
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
        login: @login,
        el: @circle_el
      )

      @friend_view = new FriendView(
        el: @friend_el,
        login: @login
      )

      @friend_view.bind("remove_user",
        _.bind(@circle_view_list.remove_all_circle_user, @circle_view_list))

      @friend_view.othe_circle_user();