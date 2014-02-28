#= require lib/transaction_card_base

exports = window || @

class exports.ShopOrderRefundCard extends TransactionCardBase
  initialize: (options) ->
    @shop = options.shop
    super
    @transaction.bind("change:delivery_price", @change_delivery_price, @)    

  events: {
    "click .transaction-actions .btn_event" : "clickAction",
    "click .transaction-actions input:button.refuse" : "toggle_refuse",
    "click .refuse-panel input:button.refuse-confirm" : "refuse_confirm",
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
    if /^shipped_agree|unshipped_agree$/.test(event)
      @slideAfterEvent(event)
    else if /^refuse$/.test(event)
      @saveReason(event)
      StateMachine.ASYNC

  leaveApplyFailure: (event, from, to, msg) ->
    @slideAfterEvent(event) if /^shipped_agree|unshipped_agree$/.test(event)

  leaveWaitingSign: (event, from, to, msg) ->
    @slideAfterEvent(event) if /^sign$/.test(event)

  leaveApplyExpired: (event, from, to, msg) ->
    @slideAfterEvent(event) if /^shipped_agree|unshipped_agree$/.test(event)

  afterRefuse: (event, from, to, msg) ->
    @change_refuse_reason() if @current == "apply_refund"

  saveReason: (event) ->
    reason = @$('.refuse-panel textarea').val().trim()
    return if _.isEmpty(reason)
    url = @transaction.urlRoot
    $.ajax(
      url: "#{url}/refuse_reason",
      type: 'POST',
      data: {refuse_reason: reason},
      success: () =>
        @transition()
        @slideAfterEvent(event)
      error: () =>
        @back_state()
    )

  toggle_refuse: () ->
    @$(".transaction-body .refuse-panel").slideToggle()

  refuse_confirm: (event) ->
    $target = $(event.currentTarget)    
    @clickAction(event)
    $target.addClass("disabled")

  change_refuse_reason: () ->
    reason = @$('.refuse-panel textarea').val()
    button = @$(".refuse-panel input:button.refuse-confirm")
    if _.isEmpty(reason)
      button.addClass("disabled")
    else
      button.removeClass("disabled")

  realtime_url: () ->
    "/#{@shop.token}/order_refunds#{super}"

  
  change_delivery_price: () ->
    price = @$(".delivery_price")
    tag = price.text().trim().substring(0, 1)
    price.html("#{tag} #{@transaction.get('delivery_price')}")
