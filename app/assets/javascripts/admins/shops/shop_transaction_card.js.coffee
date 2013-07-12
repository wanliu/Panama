#= require 'jquery'
#= require 'backbone'
#= require 'lib/transaction_card_base'
#= require 'lib/state-machine'

exports = window || @
class ShopTransactionCard extends TransactionCardBase
  initialize:() ->
    super
    @filter_delivery_code()
    @initMessagePanel()

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
    @slideAfterEvent(event) unless /back/.test event

  beforeDelivered: (event, from, to, msg) ->
    @save_delivery_code()

  filter_delivery_code: () ->
    delivery_code = @$("input:text.delivery_code").val()
    button = @$(".delivered")
    if delivery_code == ""
      button.addClass("disabled")
    else
      button.removeClass("disabled")

  save_delivery_code: () ->
    delivery_code = @$("input:text.delivery_code").val()
    return if delivery_code == ""

    urlRoot = @transaction.urlRoot
    @transaction.fetch(
        url: "#{urlRoot}/delivery_code",
        type: "PUT",
        data: {delivery_code: delivery_code}
    )

exports.ShopTransactionCard = ShopTransactionCard
exports