#= require backbone
#= require lib/hogan
root = (window || @)

class AskBuyView extends Backbone.View
  events: 
    "click .close"                        : "hide"
    "click .submit-comment"               : 'comment'
    "keypress textarea[name='content']"   : "key_up"
    "keyup textarea[name='content']"      : 'filter_status'
    #"click [name='join']"                 : "join"
    "click .submit_report"                : "report"
    "click .create_transaction"           : "create_order"
    "keyup .answer_ask_buy_price"         : "changes"
    "keyup .answer_ask_buy_amount"        : "changes"
    "keyup .answer_ask_buy_total"         : "changes"

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @loadTemplate()

  loadTemplate: () ->
    @$backdrop = $("<div class='model-popup-backdrop in' />").appendTo("body")
    @$dialog = $("<div class='dialog-panel' />").appendTo("#popup-layout")
    @fetch_dialog () =>
      @$el = $(@render()).appendTo(@$dialog)
      # $(window).scroll()
      @textarea = @$("textarea[name='content']")
      @btn = @$(".submit-comment")
      @fetch_comment()
    #super

  fetch_dialog: (handle) ->
    $.ajax(
      url: "/ask_buy/#{@ask_buy_id}.dialog",
      success: (data) =>
        @template = data
        handle.call(@)
        @delegateEvents()
    )

  fetch_comment: () ->
    $.ajax(
      url: "/comments"
      data: {targeable_id: @ask_buy_id, targeable_type: "AskBuy"},
      success: (comments) =>
        _.each comments, (comment) =>
          @render_comment(comment)
    )

  changes: (e) ->
    $target =  $(e.currentTarget)
    $total = @$(".answer_ask_buy_total")
    $price = @$(".answer_ask_buy_price")
    $amount = @$(".answer_ask_buy_amount")

    if $target.hasClass("answer_ask_buy_price") || $target.hasClass("answer_ask_buy_amount")
      value = ($price.val() * $amount.val()) || 0
      $total.val(value.toFixed(2))
    else
      value = ($total.val() / $amount.val()) || 0
      $price.val(value.toFixed(2))

  render: () ->
    @template

  modal:() ->
    $("body").addClass("noScroll")
    
  hide: () ->
    @$dialog.remove()
    @$backdrop.remove()
    $("body").removeClass("noScroll")

  key_up: (e) ->
    @comment() if (e.keyCode == 10 || e.keyCode == 13) &&  e.ctrlKey == true

  comment: () ->
    content = @textarea.val()
    return false if _.isEmpty(content)
    $.ajax(
      url: "/ask_buy/#{@ask_buy_id}/comment",
      type: 'POST',
      data: {comment: {content: content}},
      success: (data, xhr, res) =>
        @textarea.val('')
        @render_comment(data)
      )
      error: (data, xhr, res) =>
        pnotify(type: 'error', text: "评论失败了～～～")

  filter_status: () ->
    content = @textarea.val()
    if _.isEmpty(content)
      @btn.addClass("disabled")
    else
      @btn.removeClass("disabled")

  render_comment: (data) ->
    data.created_at = new Date(data.created_at).format('yyyy-MM-dd hh:mm')
    comment = Hogan.compile($("#ask_buy-comment-template").html()).render(data)
    @$(".comments").append(comment)

  
  filter_params: () ->
    $total = @$(".answer_ask_buy_total")
    $price = @$(".answer_ask_buy_price")
    $amount = @$(".answer_ask_buy_amount")
    if @$(".submit_report").hasClass("disabled")
      return false
    
    if !$("#answer_ask_buy_shop_product_chzn .chzn-results li").hasClass("result-selected")
      @$(".shop_product_wrap").addClass("error")
      return  false
    else
      @$(".shop_product_wrap").removeClass("error")
      
    if isNaN($total.val()) || _.isEmpty($total.val())
      @$(".answer_ask_buy_total_wrap").addClass("error")
      return  false
    else
      @$(".answer_ask_buy_total_wrap").removeClass("error")

    if isNaN($price.val()) || _.isEmpty($price.val())
      @$(".answer_ask_buy_price_wrap").addClass("error")
      return  false
    else
      @$(".answer_ask_buy_price_wrap").removeClass("error")

    if isNaN($amount.val()) || _.isEmpty($amount.val())
      @$(".answer_ask_buy_amount_wrap").addClass("error")
      return  false
    else
      @$(".answer_ask_buy_amount_wrap").removeClass("error")
    return true

  report: () ->
    if @filter_params()
      $data = @$(".form_answer_ask_buy").serializeHash()
      $.ajax({
        data: $data,
        url: @$(".form_answer_ask_buy").attr("action"),
        type: "POST",
        success: () =>
          pnotify(text: '报价成功,等待买家选择!!')
          @$(".submit_report").addClass("disabled")
          @$(".form_answer_ask_buy input").attr("readonly","readonly")
        error: (data) ->
          pnotify(text: JSON.parse(data.responseText).join("<br />"), type: "error")
      })
    false

  create_order: (e) ->
    return false if $(e.currentTarget).hasClass("disabled")
    answer_ask_buy_id = $(e.currentTarget).parents(".report_line").attr("data-value-id")
    $.ajax(
      url: "/answer_ask_buy/"+answer_ask_buy_id+"/create_order",
      type: "POST",
      success: (data) =>
        window.location.href = "/people/#{@login}/transactions#open/#{data.id}/order"
      error: (ms) ->
        pnotify({text: JSON.parse(ms.responseText).join("<br />"), title: "出错了！", type: "error"})
    )

class AskBuyPreview extends Backbone.View
  events:
    "click .ask_buy .preview"     : 'launch'
    "click .ask_buy .activity_tag": "launch"

  initialize: (options) ->
    _.extend(@, options)

  launch: (event) ->
    @callback() if @callback
    id = $(event.currentTarget).parents(".ask_buy").attr("ask-buy-id")
    new AskBuyView( ask_buy_id: id, login: @login ).modal()

root.AskBuyPreview = AskBuyPreview
