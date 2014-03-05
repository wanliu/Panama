root = (window || @)

class Circle extends Backbone.Model
  set_url: (url) ->
    @urlRoot = url

  constructor: (attr, url) ->
    @set_url(url)
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

  set_url: (url) ->
    @url = url

  constructor: (models, url) ->
    @set_url(url)
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

  followers: () ->
    @fetch( url: "#{@url}/followers" )


class CircleUser extends Backbone.View
  tagName: "span"
  className: "label user"
  events:
    "click .remove_user" : "cloes_user"

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
    @user_list = new CircleList([], @remote_url)
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

  events:
    "click .remove_circle": "delete_circle"
    "click .icon-cog" : "setting_load"
    "click .update-circle": "update_circle"

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$el.html(@template.render(@model.toJSON()))

    @circle_user_list = new CircleUserList(
      model: @model,
      el: @$(".user-list"),
      remote_url: @remote_url
    )

    @$el.droppable(
      drop: _.bind(@join_friend, @)
    )

    @model.bind("remove_user", _.bind(@remove_user, @))

  setting_load: (e) ->
    id = $(e.currentTarget).attr("data-value-id")
    modal = $('#mySetting').modal({
      remote: "/people/#{@login}/circles/#{ id }",
      backdrop: true,
    })

  render: () ->
    if @model.attributes.created_type != "advance"
      $(@el).find("i.icon-edit").hide()
    @$el

  delete_circle: () ->
    if confirm("确认删除#{@model.get('name')}圈子?")
      @model.destroy()
      @$el.remove()

  join_friend: (event, ui) ->
    user_id = $(ui.helper).attr("data-value-id")
    circle = new Circle({id: @model.id}, @remote_url)
    circle.join_friend user_id,
      (model, data) =>
        @circle_user_list.user_list.add(data)
      (model, data, t) =>
        m = JSON.parse(data.responseText)
        alert(m.message)

  remove_user: (user_id) ->
    @circle_user_list.find_remove(user_id)

  update_circle: (event) ->
    return pnotify("请填写圈子名称") if @$("#circle_name").val().trim() is ""
    return pnotify("请完善地区位置") if @$("#address_area_id").val().trim() is ""
    $form = $("form.edit_circle_from")
    $.ajax(
      url: $form.attr("action")
      data: $form.serialize()
      type: 'PUT'
      dataType: "JSON"
      success: (data) =>
        @$(".edit_circle_panel").modal("hide")
        pnotify("成功修改圈子")
      error: (data) =>
        pnotify("修改圈子失败了~~~")
    )


class CircleViewList extends Backbone.View
  events:
    "click .add-circle"         : "show_add_circle"
    "click .save-circle"        : "create_circle"
    "keypress input#circle_name": "key_up"

  initialize: (options) ->
    _.extend(@, options)

    @circles = new CircleList([], @remote_url)
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
    model.set_url(@remote_url)
    circle_view = new CircleView({
      model: model,
      template: @template,
      remote_url: @remote_url
    })
    @circle_el.prepend(circle_view.render())

  show_add_circle: () ->
    @add_panel.modal("show")

  create_circle: () ->
    return pnotify("请填写圈子名称") if @$("#circle_name").val().trim() is ""
    return pnotify("请完善地区位置") if @$("#address_area_id").val().trim() is ""
    $form = $("form.create_circle_from")
    @circle = new Circle($form.serializeHash(), @remote_url)
    @circle.save({},
      success: (model, data) =>
        @circles.add(data)
        $form[0].reset()
        @add_panel.modal("hide")
        pnotify("成功添加圈子")

      error: (model, data) =>
        data = JSON.parse(data.responseText)
        # _.each data, (d) =>
        #   @$(".error").append(d)
        pnotify("添加圈子失败了~~~")
    )

  key_up: (e) ->
    @create_circle() if e.keyCode == 13

  remove_all_circle_user: (user_id) ->
    @circles.each (model) =>
      model.trigger("remove_user", user_id)

root.Circle = Circle
root.CircleList = CircleList
root.CircleViewList = CircleViewList
