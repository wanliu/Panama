#= require jquery
#= require backbone

exports = window || @

class ChangeNumberView extends Backbone.View  
  events : {
    "click .spinner-up" : "change"
    "click .spinner-down" : "change"
  }

  initialize: (options) ->
    _.extend(@, options)      
    @item_id = @el.attr("data-value-id")

  change : () ->
    @amount = @el.find(".spinner-input").val()
    $.ajax({
      type: "post",
      url: "/people/#{@login}/cart/#{@item_id }/change_number",
      data : { amount: @amount }
      dataType: "json"
    }).success((model, status, xhr) =>
      $('.cart-total span.cart-price-total').html(model.price_total)
      $('.cart-total span.cart-quantity-total').html(model.quantity_total)
    )

class exports.ChangeNumberList extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$el.each (i, item) =>
      new ChangeNumberView({el: $(item)})

