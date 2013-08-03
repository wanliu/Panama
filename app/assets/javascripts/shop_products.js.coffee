
class window.ShopProductBuy extends Backbone.View
  events: {
    "click input:button.buy" : "buy"
  }

  initialize: () ->
    @$el = $(@el)
    @login = @options.login
    @shop_product_id = @$el.attr("data-value-id")
    @amount = @$("input:text.amount")

  buy: () ->
    $.ajax(
      url: "/shop_products/#{@shop_product_id}/buy",
      type: "POST",
      data: {amount: @amount.val()}
      success: () =>
        window.location.href = "/people/#{@login}/transactions"
    )


