#= require 'jquery'
#= require 'backbone'
#= require 'lib/transaction_card_base'
#= require 'lib/state-machine'
#= require 'lib/order_export'

exports = window || @
class ShopTransactionCard extends TransactionCardBase
  initialize:() ->
    super
    @filter_delivery_code()
    @initMessagePanel()
    @countdown()
    @realtime_load()

  events:
    "click .page-header .btn" : "clickAction"
    "click button.close"      : "closeThis"
    "click .detail"           : "toggleItemDetail"
    "click .message-toggle"   : "toggleMessage"
    "keyup .delivery_code"    : "filter_delivery_code"
    "click .dprice_edit"      : "show_dprice_edit"
    "blur input:text[name=delivery_price]" : "update_dprice"
    "change select.delivery_manner_id" : "change_delivery_manner"

  states:
    initial: 'none'

    events:  [
      { name: 'refresh_online_payment',       from: 'order',             to: 'waiting_paid' },
      { name: 'refresh_bank_transfer',        from: 'order',             to: 'waiting_transfer'},
      { name: 'refresh_cash_on_delivery',     from: 'order',             to: 'waiting_delivery'}
      { name: 'refresh_paid',                 from: 'waiting_paid',      to: 'waiting_delivery' },
      { name: 'refresh_sign',                 from: 'waiting_sign',      to: 'complete'},
      { name: 'refresh_transfer',             from: 'waiting_transfer',  to: 'waiting_audit'},
      { name: 'refresh_audit_transfer',       from: 'waiting_audit',     to: 'waiting_delivery'},
      { name: 'refresh_audit_failure',        from: 'waiting_audit',     to: 'waiting_audit_failure'},
      { name: 'refresh_back',                 from: 'waiting_paid',      to: 'order'         },
      { name: 'refresh_back',                 from: 'waiting_delivery',  to: 'waiting_paid' },
      { name: 'refresh_back',                 from: 'waiting_sign',      to: 'waiting_delivery' },
      { name: 'refresh_returned',             from: 'waiting_refund',    to: 'refund' },
      { name: 'refresh_returned',             from: 'delivery_failure',  to: 'waiting_refund' },
      { name: 'refresh_returned',             from: 'waiting_delivery',  to: 'waiting_refund' },
      { name: 'refresh_returned',             from: 'waiting_sign',      to: 'waiting_refund' },
      { name: 'refresh_returned',             from: 'complete',          to: 'waiting_refund' },
      { name: 'delivered',                    from: 'waiting_delivery',  to: 'waiting_sign' }
    ]

    callbacks:
      onenterstate: (event, from, to, msg) ->
        console.log "event: #{event} from #{from} to #{to}"

  realtime_load: () ->
    @realtime.subscribe "/OrderTransaction/#{@options.id}/#{@options.shop.token}/#{@rt_options.token}/destroy", () =>
      @remove()

  getNotifyName: () ->
    super + "-seller"

  toggleItemDetail: (event) ->
    @$(".item-details").slideToggle()
    false

  setMessagePanel: () ->
    @message_panel = @$("iframe", ".transaction-footer")
    height = @$(".transaction-header").parents(".left").innerHeight() - @$(".message-toggle").height()
    @message_panel.height(height)

  initMessagePanel: () ->
    @setMessagePanel()
    @message_panel.show()

  toggleMessage: () ->
    @setMessagePanel()
    @message_panel.slideToggle()
    false

  leaveWaitingDelivery: (event, from, to, msg) ->
    _event = event
    if !/back/.test(_event) && !/refresh_returned/.test(_event)
      @save_delivery_code () =>
        @slideAfterEvent(_event)

  filter_delivery_code: () ->
    if @delivery_manner_el().text().trim() == "快递运输"
      delivery_code = @$("input:text.delivery_code").val()
      button = @$(".delivered")
      if delivery_code == ""
        button.addClass("disabled")
      else
        button.removeClass("disabled")


  save_delivery_code: (cb) ->
    delivery = @$("input:text.delivery_code")
    logistics = @$("select[name=logistics_company_id]")
    delivery_manner = @delivery_manner_el()

    if delivery.length > 0 && logistics.length > 0 &&
     delivery_manner.length > 0
      delivery_code = delivery.val()
      logistics_company_id = logistics.val()
      delivery_manner_id = delivery_manner.val()
      urlRoot = @transaction.urlRoot
      @transaction.fetch(
        url: "#{urlRoot}/update_delivery",
        type: "PUT",
        data: {
          delivery_manner_id: delivery_manner_id,
          delivery_code: delivery_code,
          logistics_company_id: logistics_company_id},
        success: cb,
        error: () =>
          @notify("错误信息", '请填写发货单号!', "error")
          @alarm()
          @transition.cancel()
      )
    else
     cb()

  show_dprice_edit: () ->
    @$dprice_panel = @$(".dprice_panel")
    @$dprice_edit_panel = @$(".dprice_edit_panel")
    @$dprice_input = @$("input:text[name=delivery_price]")

    @$dprice_panel.hide()
    @$dprice_edit_panel.show()
    @$dprice_input.focus()

  update_dprice: () ->
    old_price = @$dprice_panel.attr("data-value")
    new_price = @$dprice_input.val()

    unless /^\d+.?\d+$/.test(new_price)
      pnotify(title: "错误信息", text: "请输入正确运费！", type: "error")
      return

    if parseFloat(old_price) isnt parseFloat(new_price)
      @transaction.fetch(
        url: "#{@transaction.urlRoot}/update_delivery_price",
        data: {delivery_price: new_price},
        type: "PUT",
        success: () =>
          price = @$dprice_panel.text().trim()
          price = price.replace(price.substring(1, price.length), " #{new_price}")
          @$dprice_panel.html(price)
          @$dprice_panel.show()
          @$dprice_edit_panel.hide()
      )
    else
      @$dprice_panel.show()
      @$dprice_edit_panel.hide()

  change_delivery_manner: () ->
    if @delivery_manner_el().text().trim() == "快递运输"
      @$(".express-info").show()
      @filter_delivery_code()
    else
      @$(".express-info").hide()
      @$(".delivered").removeClass("disabled")


  delivery_manner_el: () ->
    @$("select.delivery_manner_id>option:selected")

exports.ShopTransactionCard = ShopTransactionCard
exports