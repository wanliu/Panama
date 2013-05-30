
define ['jquery', 'backbone', "lib/transaction_card_base"],
($, Backbone, Transaction) ->
  class ShopOrderRefundCard extends Transaction.TransactionCardBase
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
        { name: 'refuse',        from: 'apply_refund',      to: 'refuse' },
        { name: 'agree',         from: 'apply_refund',      to: 'waiting_delivery' },
        { name: 'sign',          from: 'waiting_sign',      to: 'complete'}
      ]

    leaveWaitingSign: (event, from, to, msg) ->
      @slideAfterEvent(event)

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
