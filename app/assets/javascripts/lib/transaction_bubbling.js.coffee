#订单聊天冒泡提醒


root = window || @

class TransactionBubbling
  channel_key: "transaction_chat_notice"

  constructor: (options) ->
    @url = options.url

    @bind_pmessage()

  bind_pmessage: () ->
    pm.bind(@channel_key, (message) =>
      $.notifier({
        title: "有新的消息",
        avatar: message.send_user.icon_url,
        text: "#{message.send_user.login}: #{message.content}",
        addclass: "stack-bottomright",
        stack: "stack_bottomright"
      })
    )

  order_uri: (id) ->
    url = "#{@url}#{id}"
    "<a style='word-wrap:break-word;' href='#{url}'>#{url}</a>"


root.TransactionBubbling = TransactionBubbling