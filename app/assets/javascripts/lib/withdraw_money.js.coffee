#

root = (window || @)

class root.WithDrawMoneyView extends Backbone.View
  expand_class: "_collapse"

  events: {
    "click .bank-wrapper input:radio" : "check",
    "click .expand" : "expand",
    "submit form.create" : "draw_money",
    "keyup input.money" : "filter_money"
  }

  initialize: () ->
    @$bank_wrap = @$(".bank-wrapper")
    @money = @options.money
    @current_user = @options.current_user 
    @$form = @$("form.create")
    @$money = $("input.money", @$form)
    @money_wrap = @$(".money_wrap")
    @money_mgs = @$("label.message")

  check: (event) ->
    bank_id = $(event.currentTarget).val()

    width =_.max(_.map $(".bank", @$bank_wrap), (elem) -> $(elem).width())

    $(".bank", @$bank_wrap).removeClass("active")
    $(".bank_#{bank_id}", @$bank_wrap).addClass("active")
    @$bank_wrap.addClass(@expand_class)

    active = $(".bank.active", @$bank_wrap)
    height = active.height()    

    _.reduce $(".bank:not(.active)", @$bank_wrap), (mem, elem) =>
      $(elem).css(
        height: height,
        width: width,
        left: mem * 3
        zIndex: mem
        top: mem * 3)
      mem += 1      
    , 1

    active.css(
      height: height,
      width: width,
      left: 0,
      zIndex: 90,
      top: 0
    )

  expand: () ->
    @$bank_wrap.removeClass(@expand_class)

  draw_money: () ->    
    return false unless @filter_money()     
    data = @$form.serializeHash()
    $.ajax(
      url: @$form.attr("action"),
      type: "POST",
      data: {withdraw: data},
      success: (data) =>
        # @$form[0].reset()
        pnotify(text: "提现成功!")
        setTimeout( () =>
          location.href = "/people/#{@current_user}"
        , 500)
      error: (data) =>
        ms = JSON.parse(data.responseText)
        pnotify(text: ms.join("<br />"), type: "error")
    )
    false

  filter_money: () ->
    unless $.isNumeric(@$money.val())
      @notify_msg("请输入正确定的数字格式！")
      return false

    if parseFloat(@$money.val()) < 0.01      
      @notify_msg("不能少于0.01")
      return false

    if parseFloat(@$money.val()) > @money
      @notify_msg("你的余额不足!")
      return false

    @money_wrap.removeClass("error")
    @money_mgs.html('')
    true

  notify_msg: (msg) ->
    @money_wrap.addClass("error")
    @money_mgs.html(msg)
    @$money.focus()

