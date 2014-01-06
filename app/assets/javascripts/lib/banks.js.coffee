# 银行卡管理

root = (window || @)

class root.BanksView extends Backbone.View
  events: {
    "submit form.bank" : "create"
  }
  initialize: () ->
    @remote_url = @options.remote_url
    @$form = $("form.bank")

  render: () ->

  create: () ->    
    data = @$form.serializeHash()
    $.ajax(
      url: @remote_url,
      type: 'POST',
      data: data,
      success: (data) =>  
        @add_one(data)  
        @$form[0].reset()

      error: (data) =>
        msg = JSON.parse(data.responseText)
        pnotify(text: msg.join("<br />"), type: "error")
    )
    false

  add_one: (item) ->
    @$(".bank_list tbody .notify").remove()
    @$(".bank_list tbody").append(item)

