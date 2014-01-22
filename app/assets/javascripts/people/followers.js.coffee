#describe: 关注某个人

exports = window || @

class exports.Followers extends Backbone.View

  events:
    'click .follow'   : 'bind_follow'
    'click .unfollow' : 'bind_unfollow'

  initialize: (options) ->
    _.extend(@, options)
    @urlRoot = "/people/#{@login}/followings"

  send_follow: (follow_id) ->
    if @follow_type is 'User'
      @ajax_url = "#{@urlRoot}/User/#{follow_id}"
      @ajax_data = {user_id: follow_id}
    else
      @ajax_url = "#{@urlRoot}/Shop/#{follow_id}"
      @ajax_data = {shop_id: follow_id}

    $.ajax({
      type: "post",
      url: @ajax_url,
      data: @ajax_data,
      dataType: "json",
      success: (data, xhr, res) =>
        @follow_hide(data)
      error: (data, xhr, res) =>
        pnotify(type: error, text: '关注失败～～～')
    })

  send_unfollow: (unfollow_id, people_id) ->
    $.ajax({
      type: "delete",
      url: "#{@urlRoot}/#{unfollow_id}",
      data: {id: unfollow_id},
      dataType: "json",
      success: (data, xhr, res) =>
        @follow_show(people_id)
      error: (data, xhr, res) =>
        pnotify(type: error, text: '取消关注失败～～～')
    })

  follow_hide: (data) ->
    @$(".follow").removeClass("follow").addClass("unfollow")
    @$(".unfollow").html("取消关注").attr("data-value", "#{data.id}")

  follow_show: (people_id) ->
    @$(".unfollow").removeClass("unfollow").addClass("follow")
    @$(".follow").html("关注").attr("data-value", "#{people_id}")

  bind_follow: () ->
    follow_id = @$(".follow").attr("data-value")
    @send_follow(follow_id)

  bind_unfollow: () ->
    unfollow_id = @$(".unfollow").attr("data-value")
    @send_unfollow(unfollow_id, @people_id)

