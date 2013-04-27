#describe: 聊天及时客户端
define ["lib/realtime_client"], (RealtimeClient) ->

  class ChatRealtimeClient extends RealtimeClient

    constructor: (remote_url) ->
      super remote_url

    #显示最近联系人
    show_contact_friend: (token, callback) ->
      @client.subscribe("/contact_friends/#{token}", callback)

    #接收信息
    receive_message: (token, callback) ->
      @client.subscribe("/chat/receive/#{token}", callback)

    #读取信息通知
    read_message_notic: (token, callback) ->
    	@client.subscribe("/chat/change/message/#{token}", callback)
