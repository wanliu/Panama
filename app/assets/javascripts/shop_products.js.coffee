
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
    state = @buy_manner()
    if state == "guarantee"
      @create_order()
    else
      @create_direct_buy()


  create_order: () ->
    $.ajax(
      url: "/shop_products/#{@shop_product_id}/buy",
      type: "POST",
      data: {amount: @amount.val()}
      success: () =>
        window.location.href = "/people/#{@login}/transactions"
    )

  create_direct_buy: () ->
    $.ajax(
      url: "/shop_products/#{@shop_product_id}/direct_buy",
      type: "POST",
      data: {amount: @amount.val()}
      success: () =>
        window.location.href = "/people/#{@login}/transactions"
    )

  cart: () ->
    form = @form_load_buy_manner()
    selector  = @$cart_el.attr('add-to-cart')
    urlAction = @$cart_el.attr('add-to-action')
    myCart.addToCart($(selector), form ,urlAction)

  direct: () ->
    window.location.href = "/people/#{@login}/transactions/#{@shop_product_id}/direct"

  buy_manner: () ->
    buy_state = $("input:radio[name=buy_manner]:checked").val()

  form_load_buy_manner: () ->
    form = @$("form")
    form.append("<input type='hidden' value='#{@buy_manner()}' name='product_item[buy_state]' />")
    form

