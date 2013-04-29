#encoding: utf-8
#describe: 聊天视图
define ["jquery", "backbone", "chats/contact_friend", "lib/realtime_client"],
($, Backbone, ContactFriendViewList, Realtime) ->
  class User extends Backbone.Model
    urlRoot: "/users"
    show: (user_id, callback) ->
      @fetch(
        url: "#{@urlRoot}/#{user_id}",
        success: callback
      )

  class ChatContact extends Backbone.View
    events: {
      "click .close_list" : "hide"
    }

    initialize: (options) ->
      _.extend(@, options)

      @friend_list_el = @el.find(".friend_list")
      #最近联系人
      @cfv_list = new ContactFriendViewList()
      @friend_list_el.html(@cfv_list.render())
      @bind_relatime()

    bind_relatime: () ->
      @client = Realtime.client(@faye_url)

      @client.subscribe @contact_show_url(), (friend) =>
        @cfv_list.add(friend)

      @client.receive_message @current_user.token, (message) =>
        @cfv_list.receive_notic(message.send_user_id)

      @client.subscribe @change_state_notic_url(), (send_user_id) =>
        @cfv_list.read_notice(send_user_id)

    contact_show_url: () ->
      "/contact_friends/#{@current_user.token}"

    change_state_notic_url: () ->
      "/chat/change/message/#{@current_user.token}"

    show_dialogue: (user_id) ->
      user = new User()
      user.show user_id, (model, data) =>
        @cfv_list.show_dilogue data

    hide: () ->
      @el.hide()

    show: () ->
      @el.show()

    toggle: () ->
      @el.toggle()
