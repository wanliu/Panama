#describe 买家退货
#= require lib/transaction_card_base

root = window || @

class OrderRefundCard extends TransactionCardBase

  initialize: () ->
    super

  events: {
    "click .refuse_protect" : "toggle_panel"
    "click input.delivered" : "clickAction",
    "keyup input:text.delivery_code" : "change_delivery_code",
  }

  states:
    initial: 'none'

    events:  [
      { name: 'refresh_shipped_agree',    from: 'apply_refund',      to: 'waiting_delivery'},
      { name: 'refresh_shipped_agree',    from: 'apply_expired',     to: 'waiting_delivery' },
      { name: 'refresh_shipped_agree',    from: 'apply_failure',     to: 'waiting_delivery' },
      { name: 'refresh_unshipped_agree',  from: 'apply_refund',      to: 'complete'},
      { name: 'refresh_unshipped_agree',  from: 'apply_expired',     to: 'complete' },
      { name: 'refresh_unshipped_agree',  from: 'apply_failure',     to: 'complete' },
      { name: 'refresh_sign',             from: 'waiting_sign',      to: 'complete'},
      { name: 'refresh_refuse',           from: 'apply_refund',      to: 'apply_failure'},
      { name: 'delivered',                from: 'waiting_delivery',  to: 'waiting_sign' }
    ]

  getNotifyName: () ->
    "order-refund-#{@options['id']}-buyer"

  change_delivery_code: () ->

    code = @$("input:text.delivery_code").val()
    button = @$('.page-header input.delivered')
    if _.isEmpty(code)
      button.addClass("disabled")
    else
      button.removeClass("disabled")

  toggle_panel: (option) ->
    @$(".connect").toggle("slow")

  afterDelivered: (event, from, to, msg) ->
    code = @$("input:text.delivery_code").val()
    return if _.isEmpty(code)
    url = @transaction.urlRoot
    @transaction.fetch(
      url: "#{url}/delivery_code",
      type: 'POST',
      data: {delivery_code: code},
      success: () =>
        @slideAfterEvent(event)
    )

root.OrderRefundCard = OrderRefundCard