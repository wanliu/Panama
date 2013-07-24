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

  events:
    "click .page-header .btn" : "clickAction"
    "click button.close"      : "closeThis"
    "click .detail"           : "toggleItemDetail"
    "click .message-toggle"   : "toggleMessage"
    "keyup .delivery_code"    : "filter_delivery_code"

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
    unless /back/.test _event
      @save_delivery_code () =>
        @slideAfterEvent(_event)

  filter_delivery_code: () ->
    delivery_code = @$("input:text.delivery_code").val()
    button = @$(".delivered")
    if delivery_code == ""
      button.addClass("disabled")
    else
      button.removeClass("disabled")

  save_delivery_code: (cb) ->
    input = @$("input:text.delivery_code")
    if input.length > 0
      delivery_code = input.val()
      urlRoot = @transaction.urlRoot
      @transaction.fetch(
        url: "#{urlRoot}/delivery_code",
        type: "PUT",
        data: {delivery_code: delivery_code},
        success: cb,
        error: () ->
          @notify("错误信息", '请填写发货单号!', "error")
          @alarm()
          @transition.cancel()
      )
    else
     cb()

exports.ShopTransactionCard = ShopTransactionCard
exports