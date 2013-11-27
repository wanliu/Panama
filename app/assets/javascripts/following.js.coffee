#describe: 个人关注的对象
root = window || @

class Follow extends Backbone.Model
  follow_type: "user"

  set_url: (login) ->
    @urlRoot = "/people/#{login}/followings"

  constructor: (attr, login) ->
    @set_url(login)
    super(attr)

  follow: (success_callback) ->
    @fetch(
      url: "#{@urlRoot}/#{@get('follow_type')}/#{@get('follow_id')}",
      type: "POST",
      success: success_callback,
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
    unless @model.has("id")
      id = @$(".unfollow").attr("data-value-id");
      @model.set({id: id})

    @model.destroy success: (model, data) =>
      @$(".unfollow").addClass("follow").removeClass("unfollow")
      @change_callback(@$(".follow"))
      @change_follow_count(-1)
      @$(".follow").html("+ 关注")

  follow: () ->
    @model.follow (model, data) =>
      @$(".follow").addClass("unfollow").removeClass("follow")
      @change_callback(@$(".unfollow"))
      @change_follow_count(1)
      @$(".unfollow").html("取消关注")

  change_callback: (button) ->
    if _.isFunction(@change_follow)
      @change_follow.call(@, button)

  change_follow_count: (number) ->
    elem = @$(".follows_count")
    if elem.length > 0
      elem.html(parseInt(elem.text())+number);


class FollowListView extends Backbone.View

  initialize: (opts) ->
    _.extend(@, opts)
    @$tbody = @$("div.follow")
    @load_all_tr()

  load_all_tr: () ->
    @$tbody.each (i, tr) =>
      id = $(tr).attr("data-value-id")
      follow_id = $(tr).attr("data-value-follow-id")

      new FollowView
        data: {
          id: id,
          follow_id: follow_id,
          follow_type: @follow_type
        },
        login: @login,
        el: $(tr),
        change_follow: (button) ->
          if button.hasClass("follow")
            button.val("关注")
            button.removeClass("btn-primary").addClass("btn-info")
          else
            button.val("取消关注")
            button.removeClass("btn-info").addClass("btn-primary")

root.Follow = Follow
root.FollowView = FollowView
root.FollowListView = FollowListView