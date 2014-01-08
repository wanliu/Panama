#= require lib/payments
#交易付款

exports = window || @

class PayMentView extends PayMentsView
  events : {
    "click .btn_paid" : "paid"
  }

  initialize: () ->
    _.extend(@, @options)
    super

  paid: () ->
    data = @serialize @$el.serializeHash()

    $.ajax(
      url: @remote_url,
      data: data,
      dataType: "script",
      error: () ->
    )


class exports.TransactionPayment extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)

    @button = @$(".pay-button")
    @filter_state()

    new PayMentView(
      el: @$("form.payment"),
      remote_url: @remote_url
    )

  filter_state: () ->
    if @model.total > @model.money
      @button.addClass("disabled")
    else
      @button.removeClass("disabled")
