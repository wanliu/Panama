
class window.ShopProductToolbar extends Backbone.View
  events: {
    "click .toolbar .buy" : "buy"
    "click .toolbar .cart" : "cart"
  }

  initialize: () ->
    @$el = $(@el)
    @login = @options.login
    @shop_product_id = @$el.attr("data-value-id")
    @amount = @$("input:text.amount")
    @$cart_el = $(".toolbar .cart")

  buy: () ->
    $.ajax(
      url: "/shop_products/#{@shop_product_id}/buy",
      type: "POST",
      data: {amount: @amount.val()}
      success: () =>
        window.location.href = "/people/#{@login}/transactions"
    )

  cart: () ->
    selector  = @$cart_el.attr('add-to-cart')
    urlAction = @$cart_el.attr('add-to-action')
    myCart.addToCart($(selector), @$("form") ,urlAction)


