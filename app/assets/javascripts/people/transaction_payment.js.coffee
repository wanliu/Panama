#= require lib/payments
#交易付款

exports = window || @

class PayMentView extends PayMentsView
  events : {
    "click .btn_paid" : "online_paid"
  }

  initialize: () ->
    _.extend(@, @options)
    super

  online_paid: () ->
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
    @model = new Backbone.Model(@model)
    @model.bind("change:stotal", @change_stotal, @)

    @client = window.clients
    @client.monitor "/transactions/#{@model.id}/change_info", (data) =>
      @model.set(data.info)

    @button = @$(".pay-button")
    @filter_state()

    new PayMentView(
      el: @$("form.payment"),
      remote_url: @remote_url
    )

  change_stotal: () ->    
    @filter_state()

  filter_state: () ->
    if @model.get("stotal") > @model.get("money")
      @button.addClass("disabled").removeClass("btn-primary")
    else
      @button.removeClass("disabled").addClass("btn-primary")
