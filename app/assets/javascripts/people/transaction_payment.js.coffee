#交易付款

exports = window || @

class exports.TransactionPayment extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)

    @button = @$(".pay-button")
    @filter_state()

  filter_state: () ->
    if @model.total > @model.money
      @button.addClass("disabled")
    else
      @button.removeClass("disabled")
