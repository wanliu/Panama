#= require 'lib/transaction_card_base'
#= require 'lib/state-machine'
#= require 'lib/order_export'

exports = window || @
class ShopTransactionCard extends TransactionCardBase
  initialize:() ->
    @shop = @options.shop
    super
    @filter_delivery_code()
    @initMessagePanel()
    @countdown()

  events:
    "click .transaction-actions .btn_event" : "clickAction"
    "click button.close"      : "closeThis"
    "click .detail"           : "toggleItemDetail"
    "click .message-toggle"   : "toggleMessage"
    "keyup input.delivery_code"    : "filter_delivery_code"
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

  toggleItemDetail: (event) ->
    @$(".item-details").slideToggle()
    false

  initMessagePanel: () ->
  #   @setMessagePanel()
  #   @message_panel.show()

  # toggleMessage: () ->
  #   @setMessagePanel()
  #   @message_panel.slideToggle()
  #   false

  leaveWaitingDelivery: (event, from, to, msg) ->
    _event = event
    if !/back/.test(_event) && !/refresh_returned/.test(_event) && @filter_delivery_code()
      @save_delivery_code () =>
        @slideAfterEvent(_event)
    else
      @alarm()
      @transition.cancel()

  filter_delivery_code: () ->
    button = @$(".delivered")
    delivery_code = @$("input:text.delivery_code")
    if delivery_code.length < 1
      button.addClass("disabled").removeAttr("event-name")
    else
      button.removeClass("disabled").attr("event-name", "delivered")
      true

  save_delivery_code: (cb) ->
    delivery = @$("input:text.delivery_code")
    #logistics = @$("select[name=logistics_company_id]")
    #delivery_manner = @delivery_manner_el()

    if delivery.length > 0
      delivery_code = delivery.val()
      urlRoot = @transaction.urlRoot
      @transaction.fetch(
        url: "#{urlRoot}/update_delivery",
        type: "PUT",
        data: {
          delivery_code: delivery_code}
        success: cb,
        error: () =>
          @notify("错误信息", '请填写发货单号!', "error")
          @back_state()
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

    unless /^\d+(.\d+)?$/.test(new_price)
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
    if @is_delivery_express()
      @$(".express-info").show()
      @filter_delivery_code()
    else
      @$(".express-info").hide()
      @$(".delivered").removeClass("disabled").attr("event-name", "delivered")

  delivery_manner_el: () ->
    @$("select.delivery_manner_id>option:selected")

  is_delivery_express: () ->

  realtime_url: () ->
    "notify:/#{@shop.token}/transactions#{super}"

exports.ShopTransactionCard = ShopTransactionCard
exports