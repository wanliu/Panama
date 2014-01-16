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
      $total.val(($price.val() * $amount.val()).toFixed(2))
    else
      $price.val(($total.val() / $amount.val()).toFixed(2))

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
      success: (comment) =>
        @textarea.val('')
        @render_comment(comment)
      )

  filter_status: () ->
    content = @textarea.val()
    if _.isEmpty(content)
      @btn.addClass("disabled")
    else
      @btn.removeClass("disabled")

  render_comment: (comment) ->
    comment = Hogan.compile($("#ask_buy-comment-template").html()).render(comment)
    @$(".comments").append(comment)

  # join: () ->
  #   $.ajax(
  #     url: "/ask_buy/#{@ask_buy_id}/join",
  #     type: "POST",
  #     success: () ->
  #       pnotify(text: "参与求购成功，等待用户付款！")
  #     error: (xhr) ->
  #       pnotify(text: JSON.parse(xhr.responseText).join(""),type: "error")
  #   )
  
  filter_params: () ->
    $total = @$(".answer_ask_buy_total")
    $price = @$(".answer_ask_buy_price")
    $amount = @$(".answer_ask_buy_amount")
    if @$(".submit_report").hasClass("disabled")
      return false
      
    if _.isEmpty($("#answer_ask_buy_shop_product").val())
      @$(".shop_product_wrap").addClass("error")
      return  false
      
    if isNaN($total.val()) || _.isEmpty($total.val())
      @$(".answer_ask_buy_total_wrap").addClass("error")
      return  false

    if isNaN($price.val()) || _.isEmpty($price.val())
      @$(".answer_ask_buy_price_wrap").addClass("error")
      return  false

    if isNaN($amount.val()) || _.isEmpty($amount.val())
      @$(".answer_ask_buy_amount_wrap").addClass("error")
      return  false
    return true

  report: () ->
    if @filter_params()
      $data = @$(".form_answer_ask_buy").serializeHash()
      $.ajax({
        data: $data,
        url: @$(".form_answer_ask_buy").attr("action"),
        type: "POST",
        success: () =>
          pnotify(text: '报价成功!!')
          @$(".submit_report").addClass("disabled")
          @$(".form_answer_ask_buy input").attr("readonly","readonly")
        error: (data) ->
          pnotify(text: JSON.parse(data.responseText).join("<br />"), type: "error")
      })
    false

  create_order: (e) ->
    answer_ask_buy_id = $(e.currentTarget).parents(".report_line").attr("data-value-id")
    $.ajax(
      url: "/answer_ask_buy/"+answer_ask_buy_id+"/create_order",
      type: "POST",
      success: () =>
        window.location.href = "/people/#{@login}/transactions"
      error: (data) ->
        pnotify({text: JSON.parse(data.responseText).join("<br />"), title: "出错了！", type: "error"})
    )

class AskBuyPreview extends Backbone.View
  events:
    "click .ask_buy .preview"     : 'launch'
    "click .ask_buy .activity_tag": "launch"

  initialize: (options) ->
    _.extend(@, options)

  launch: (event) ->
    id = $(event.currentTarget).parents(".ask_buy").attr("ask-buy-id")
    new AskBuyView( ask_buy_id: id, login: @login ).modal()

root.AskBuyPreview = AskBuyPreview
