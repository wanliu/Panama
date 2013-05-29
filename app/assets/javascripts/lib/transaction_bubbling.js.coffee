#订单聊天冒泡提醒
define ["jquery", "postmessage", "notify"], ($) ->

  class TransactionBubbling
    channel_key: "transaction_chat_notice"

    constructor: (options) ->
      @url = options.url

      @bind_pmessage()

    bind_pmessage: () ->
      pm.bind(@channel_key, (message) =>
        $.pnotify({
          title: "有新的消息",
          text: "#{message.send_user.login}: #{message.content}<br />#{@order_uri(message.owner.id)}",
          addclass: "stack-bottomright",
          stack: "stack_bottomright"
        });
      )

    order_uri: (id) ->
      url = "#{@url}#{id}"
      "<a style='word-wrap:break-word;' href='#{url}'>#{url}</a>"


