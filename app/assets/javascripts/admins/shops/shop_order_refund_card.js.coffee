#= require lib/transaction_card_base

exports = window || @

class exports.ShopOrderRefundCard extends TransactionCardBase
  initialize: (options) ->
    @shop = options.shop
    super

  events: {
    "click .page-header input:button.sign" : "clickAction",
    "click .page-header input:button.refuse" : "toggle_refuse",
    "click .page-header input:button.agree" : "clickAction",
    "click .refuse-panel input:button.refuse-confirm" : "clickAction",
    "keyup .refuse-panel textarea" : "change_refuse_reason"
  }

  states:
    initial: 'none'

    events:  [
      { name: 'refuse',             from: 'apply_refund',      to: 'apply_failure' },
      { name: 'shipped_agree',      from: 'apply_refund',      to: 'waiting_delivery' },
      { name: 'unshipped_agree',    from: 'apply_refund',      to: 'complete' },
      { name: 'sign',               from: 'waiting_sign',      to: 'complete'},
      { name: 'shipped_agree',      from: 'apply_failure',     to: 'waiting_delivery' },
      { name: 'unshipped_agree',    from: 'apply_failure',     to: 'complete'},
      { name: 'shipped_agree',      from: 'apply_expired',     to: 'waiting_delivery' },
      { name: 'unshipped_agree',    from: 'apply_expired',     to: 'complete'},
      { name: 'refresh_delivered',  from: 'waiting_delivery',  to: 'waiting_sign'}
    ]

  leaveApplyRefund: (event, from, to, msg) ->
    @slideAfterEvent(event) if /^shipped_agree|unshipped_agree$/.test(event)

  leaveApplyFailure: (event, from, to, msg) ->
    @slideAfterEvent(event) if /^shipped_agree|unshipped_agree$/.test(event)

  leaveWaitingSign: (event, from, to, msg) ->
    @slideAfterEvent(event) if /^sign$/.test(event)

  afterRefuse: (event, from, to, msg) ->
    reason = @$('.refuse-panel textarea').val()
    return if _.isEmpty(reason)
    url = @transaction.urlRoot
    @transaction.fetch(
      url: "#{url}/refuse_reason",
      type: 'POST',
      data: {refuse_reason: reason},
      success: () =>
        @slideAfterEvent(event)
    )

  toggle_refuse: () ->
    @$(".transaction-body .refuse-panel").slideToggle()

  change_refuse_reason: () ->
    reason = @$('.refuse-panel textarea').val()
    button = @$(".refuse-panel input:button.refuse-confirm")
    if _.isEmpty(reason)
      button.addClass("disabled")
    else
      button.removeClass("disabled")

  realtime_url: () ->
    "notify:/#{@shop.token}/order_refunds#{super}"
