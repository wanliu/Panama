#= require jquery
#= require backbone
#= require lib/transaction_card_base


class ShopOrderRefundCard extends TransactionCardBase
  initialize: () ->
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
      { name: 'refuse',          from: 'apply_refund',      to: 'refuse' },
      { name: 'shipped_agree',   from: 'apply_refund',      to: 'waiting_delivery' },
      { name: 'unshipped_agree', from: 'apply_refund',      to: 'complete' },
      { name: 'sign',            from: 'waiting_sign',      to: 'complete'},
      { name: 'unshipped_agree', from: 'apply_failure',     to: 'complete'},
      { name: 'shipped_agree',   from: 'apply_failure',     to: 'complete' }
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
