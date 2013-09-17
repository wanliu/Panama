
root = window || @

class ShopProductModel extends Backbone.Model

  urlRoot: '/shop_products'


class ShopProductView extends Backbone.View

  events:
    "click [data-dismiss=modal]": "close"

  initialize: (options) ->
    _.extend(@, options)
    @loadTemplate () =>
      @$backdrop = $("<div class='model-popup-backdrop in' />").appendTo("body")
      @$dialog = $("<div class='dialog-panel' />").appendTo("#popup-layout")
      @$el = $(@render()).appendTo(@$dialog)
      $(window).scroll()
    super

  loadTemplate: (handle) ->
    $.get @model.url() + ".dialog", (data) =>
      @template = data
      handle.call(@)
      @delegateEvents()

  render: () ->
    tpl = Hogan.compile(@template)
    tpl.render(@model.attributes)

  modal: () ->
    $("body").addClass("noScroll")

  unmodal: () ->
    $("body").removeClass("noScroll")

  close: () ->
    @$dialog.remove()
    @$backdrop.remove()
    @unmodal()


class ShopProductPreview extends Backbone.View

  events:
    "click .shop_product .preview"    : "launchShopProduct",
    "click .shop_product .buy"        : "buy"

  initialize: (options) ->
    _.extend(@, options)

  launchShopProduct: (event) ->
    @load_view(event.currentTarget)
    @model.fetch success: (model) =>
      view = new ShopProductView({
        el         : @$el,
        model      : @model,
        product_id : @product_id
      })
      view.modal()
    false

  buy: (event) ->
    @load_view(event.currentTarget)
    try
      $.ajax(
        url: "/shop_products/#{@model.id}/direct_buy",
        type: "POST",
        data: {amount: 1}
        success: (data) =>
          window.location.href = "/people/#{data.buyer_login}/transactions"
        error: (data) ->
          pnotify({text: JSON.parse(data.responseText).join("<br />"), title: "出错了！", type: "error"})
      )
      false
    catch error
      false

  load_view: (target) ->
    @el = $(target).parents(".shop_product")
    @model = new ShopProductModel({id: @el.attr('shop-product-id')})
    @delegateEvents()

class ShopProductToolbar extends Backbone.View
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
      error: (data) ->
        pnotify({text: JSON.parse(data.responseText).join("<br />"), title: "出错了！", type: "error"})
    )

  create_direct_buy: () ->
    $.ajax(
      url: "/shop_products/#{@shop_product_id}/direct_buy",
      type: "POST",
      data: {amount: @amount.val()}
      success: () =>
        window.location.href = "/people/#{@login}/transactions"
      error: (data) ->
        pnotify({text: JSON.parse(data.responseText).join("<br />"), title: "出错了！", type: "error"})
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


root.ShopProductModel = ShopProductModel
root.ShopProductView = ShopProductView
root.ShopProductPreview = ShopProductPreview
root.ShopProductToolbar = ShopProductToolbar
