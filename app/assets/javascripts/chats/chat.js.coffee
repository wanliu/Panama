#encoding: utf-8
#describe: 聊天视图
define [
"jquery",
"backbone",
"chats/contact_friend",
"chats/chat_realtime_client"],
($, Backbone, ContactFriendViewList, RealtimeClient) ->

  class ChatViewList extends Backbone.View
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
      @realtime_client = new RealtimeClient(@faye_url)
      @realtime_client.show_contact_friend(@current_user.id, (friend) =>
        @cfv_list.add(friend)
      )

    hide: () ->
      @el.hide()

    show: () ->
      @el.show()

    toggle: () ->
      @el.toggle()

