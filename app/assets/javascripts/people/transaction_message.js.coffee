#describe: 交易聊天

define ["jquery", "backbone"], ($, Backbone) ->

  class TransactionMessage extends Backbone.View
    events: {
      "submit .foot>form" : "send_message",
      "keyup textarea[name=content]" : 'filter_send_state'
    }

    initialize: (options) ->
      _.extend(@, options)

      @$message_panel = @$(".message_panel")
      @$messages = @$(".messages")
      @$form = @$(".foot>form")
      @$button = @$form.find("input:submit")
      @$content = @$("textarea[name=content]")
      @max_scrollTop()

    send_message: () ->
      data = @form_serialize()
      return false if not data["content"]? || data["content"] == ""
      $.ajax(
        url: "/receive_order_messages"
        data: {message: data}
        type: "POST"
        success: (data, xhr) =>
          @add_message(data)
          @$content.val('')
      )
      false

    add_message: (data) ->
      @$messages.append(data)
      @max_scrollTop()

    max_scrollTop: () ->
      @$message_panel.scrollTop(99999999999)

    form_serialize: () ->
      ms = @$form.serializeArray()
      data = {}
      _.each ms, (m) =>
        data[m.name] = m.value

      data

    filter_send_state: () ->
      content = @$content.val().trim()
      if content is ""
        @$button.addClass("disabled")
      else
        @$button.removeClass("disabled")
