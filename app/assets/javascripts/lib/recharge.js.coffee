#= require lib/payments
# description: 充值

root = (window || @)

class root.RechargeView extends PayMentsView
  events: {
    "click .btn_paid" : "paid"
  }

  initialize: () ->
    @remote_url = @options.remote_url
    @$el = $(@el)
    @$input = @$("input:text[name='money']")

  paid: () ->
    data = @serialize @$el.serializeHash()  

    unless /^\d+(:?\.\d+)?$/.test data.money
      pnotify(text: "请填写正确的金额!", type: "warning")
      @$input.focus()
      return 

    if parseFloat(data.money) < 0.01
      pnotify(text: "小数点不能超过三位", type: "warning")
      @$input.focus()
      return
    
    $.ajax(
      url: @remote_url,
      data: data,
      dataType: "script",
      error: (data) ->
        ms = JSON.parse(data.responseText)
        pnotify(text: ms.join("<br />"), type: "error")
    )
