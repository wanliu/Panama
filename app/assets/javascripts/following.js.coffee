#describe: 个人关注的对象
root = window || @

class Follow extends Backbone.Model
  follow_type: "user"

  set_url: (login) ->
    @urlRoot = "/people/#{encodeURI(login)}/followings"

  constructor: (attr, login) ->
    @set_url(login)
    super(attr)

  follow: (success_callback, error_callback) ->
    @fetch(
      url: "#{@urlRoot}/#{@get('follow_type')}/#{@get('follow_id')}",
      type: "POST",
      success: success_callback,
      error: error_callback
    )

  unfollow: (success_callback, error_callback) ->
    @fetch(
      url: "#{@urlRoot}/#{@get('follow_type')}/unfollow/#{@get('follow_id')}",
      type: "DELETE",
      success: success_callback,
      error: error_callback
    )


class FollowView extends Backbone.View
  data: { }

  events:
    "click .unfollow" : "unfollow",
    "click .follow"   : "follow"

  initialize: (opts) ->
    _.extend(@, opts)
    @model = new Follow(@data, @login);

  unfollow: () ->

    @model.unfollow (model, data) =>
      @$(".unfollow").addClass("follow").removeClass("unfollow")
      @change_callback(@$(".follow"))
      @change_follow_count(-1)
      @$(".follow").html("+关注")
      @trigger("unfollow")
    , (model, xhr) =>
      @notify_msg(xhr.responseText)      

  follow: () ->
    @model.follow (model, data) =>
      @$(".follow").addClass("unfollow").removeClass("follow")
      @change_callback(@$(".unfollow"))
      @change_follow_count(1)      
      @$(".unfollow").html("取消关注")
      @trigger("follow")
    ,(model, xhr) =>
      @notify_msg(xhr.responseText)


  change_callback: (button) ->
    if _.isFunction(@change_follow)
      @change_follow.call(@, button)

  change_follow_count: (number) ->
    elem = @$(".follows_count")
    if elem.length > 0
      elem.html(parseInt(elem.text())+number);

  notify_msg: (text) ->
    try
      ms = JSON.parse(text).join("<br />")
      pnotify(text: ms, type: "error")
    catch error
      pnotify(text: text, type: "error")

  change_follow: (button) ->
    if button.hasClass("follow")
      button.val("+关注")
      button.removeClass("label-important").addClass("label-success")
    else
      button.val("取消关注")
      button.removeClass("label-success").addClass("label-important")

class FollowListView extends Backbone.View

  initialize: (opts) ->
    _.extend(@, opts)
    @$tbody = @$("div.follow")
    @load_all_tr()

  load_all_tr: () ->
    @$tbody.each (i, tr) =>
      follow_id = $(tr).attr("data-value-follow-id")
      @bindFollow({follow_id: follow_id}, $(tr))


  bindFollow: (data, el) ->
    new FollowView(
      data: _.extend({
        follow_type: @follow_type
      }, data),
      login: @login,
      el: el
    )



root.Follow = Follow
root.FollowView = FollowView
root.FollowListView = FollowListView