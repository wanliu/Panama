#describe: 聊天及时客户端
define ["lib/realtime_client"], (RealtimeClient) ->

  class ChatRealtimeClient extends RealtimeClient

    constructor: (remote_url) ->
      super remote_url

    show_contact_friend: (uid, callback) ->
      @client.subscribe "/contact_friends/#{uid}", callback
