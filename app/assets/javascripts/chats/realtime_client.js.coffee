#describe: 聊天及时客户端
define ["lib/realtime_client"], (RealtimeClient) ->

  class ChatRealtimeClient extends RealtimeClient

    constructor: (remote_url) ->
      super remote_url

    show_contact_friend: (token, callback) ->
      @client.subscribe("/contact_friends/#{token}", callback)

    receive_message: (token, callback) ->
      @client.subscribe("/chat/receive/#{token}", callback)