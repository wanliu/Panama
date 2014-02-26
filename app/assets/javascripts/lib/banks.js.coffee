# 银行卡管理

root = (window || @)

class root.BanksView extends Backbone.View
  events: {
    "submit form.bank"              : "create"
    "click .icon-trash"             : "soft_delete"
    "keyup .bank_code>input:text"   : "show_bank_code"
  }
  initialize: () ->
    @remote_url = @options.remote_url
    @$form = $("form.bank")

  show_bank_code: (event) ->
    bank_code = @$(".bank_code>input")
    unless event.keyCode < 45 || event.keyCode > 57
      bank_code.val(bank_code.val().replace(/(\w{4})(?=\w)/g,"$1 "))

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

  soft_delete: (e) ->
    tr = $(e.currentTarget).parents("tr")
    bank_id = tr.attr("id")
    $.ajax({
      url: @remote_url+"/"+bank_id,
      type: "delete",
      success: () =>
        pnotify(text: "删除银行成功。。。")
        @remove_one(tr)
    })

  remove_one: (tr) ->
    tr.remove()

