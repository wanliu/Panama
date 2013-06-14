#describe: 个人关注的对象
#= require jquery
#= require backbone

exports = window || @

class Follow extends Backbone.Model
  follow_type: null

  set_url: (login) ->
    @urlRoot = "/people/#{login}/followings"

  constructor: (attr, login, follow_type) ->
    @follow_type = follow_type
    @set_url(login)
    super(attr)

  follow: (success_callback) ->
    @fetch(
      url: "#{@urlRoot}/#{@follow_type}/#{@get('follow_id')}",
      type: "POST",
      success: success_callback,
    )

class FollowView extends Backbone.View
  events: {
    "click input:button.unfollow" : "unfollow",
    "click input:button.follow" : "follow"
  }
  initialize: (opts) ->
    _.extend(@, opts)

  unfollow: () ->
    @model.destroy success: (model, data) =>
      @change_class(@$("input:button.unfollow"))

  follow: () ->
    @model.follow (model, data) =>
      @change_class(@$("input:button.follow"))

  change_class: (button) ->
    if button.hasClass("unfollow")
      button.val("关注")
      button.removeClass("unfollow").removeClass("btn-primary")
      .addClass("follow").addClass("btn-info")
    else
      button.val("取消关注")
      button.removeClass("follow").removeClass("btn-info")
      .addClass("unfollow").addClass("btn-primary")

class FollowListView extends Backbone.View

  initialize: (opts) ->
    _.extend(@, opts)
    @$tbody = @$("tbody>tr")
    @load_all_tr()

  load_all_tr: () ->
    @$tbody.each (i, tr) =>
      id = $(tr).attr("data-value-id")
      follow_id = $(tr).attr("data-value-follow-id")
      follow = new Follow({
          id: id,
          follow_id: follow_id
        }, @login, @follow_type)

      new FollowView(
        model: follow,
        el: $(tr)
      )

exports.FollowListView = FollowListView
exports