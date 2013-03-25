define ["jquery", "backbone"], ($, Backbone) ->

  class Following extends Backbone.View

    events: {
      "click .following"   : "following"
      "click .unfollowing" : "unfollowing"
    }

    initialize: (@options) ->
      _.extend(@, options)

    url: () ->
      "/people/#{@login}/followings"

    send_following: (following_id) ->
      debugger
      switch @following_type
        when "User" then $.post("#{@url()}/user/#{following_id}", {user_id: following_id}, "json")
        when "Shop" then $.post("#{@url()}/shop/#{following_id}", {shop_id: following_id}, "json")

    following: () ->
      following_id = $(".following").attr("data-value")
      @send_following(following_id)

    unfollowing: () ->
      following_id = $(".unfollowing").attr("data-value")
      @send_following(following_id)


  Following