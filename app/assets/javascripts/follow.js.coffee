#= require jquery
#= require backbone

root = window || @

class Follow extends Backbone.View

  events: {
    "click .follow"   : "bind_follow"
    "click .unfollow" : "bind_unfollow"
  }


  initialize: (@options) ->
    _.extend(@, options)


  url: () ->
    "/people/#{@login}/followings"


  send_follow: (follow_id) ->
    if @follow_type == "User"
      @ajax_url = "#{@url()}/user/#{follow_id}"
      @ajax_data = {user_id: follow_id}

    if @follow_type == "Shop"
      @ajax_url = "#{@url()}/shop/#{follow_id}"
      @ajax_data = {shop_id: follow_id}

    $.ajax({
      type: "post",
      url: @ajax_url,
      data: @ajax_data,
      dataType: "json",
      success: (data) =>
       @follow_hide(data)
    })


  send_unfollow: (unfollow_id, people_id) ->
    $.ajax({
        type: "delete",
        url: "#{@url()}/#{unfollow_id}",
        data: {id: unfollow_id},
        dataType: "json",
        success: () =>
          @follow_show(people_id)
      })


  follow_hide: (data) ->
    $(".follow").removeClass("follow").addClass("unfollow")
    $(".unfollow").html("取消关注")
    $(".unfollow").attr("data-value", "#{data.id}")


  follow_show: (people_id) ->
    $(".unfollow").removeClass("unfollow").addClass("follow")
    $(".follow").html("关注")
    $(".follow").attr("data-value", "#{people_id}")


  bind_follow: () ->
    follow_id = $(".follow").attr("data-value")
    @send_follow(follow_id)


  bind_unfollow: () ->
    unfollow_id = $(".unfollow").attr("data-value")
    @send_unfollow(unfollow_id, @people_id)

root.Follow = Follow