
root = window || @

class ShopProductModel extends Backbone.Model

  urlRoot: '/shop_products'

class ShopProductView extends Backbone.View

  events:
    "click [data-dismiss=modal]": "close"

  initialize: (options) ->
    _.extend(@, options)

    @loadTemplate () =>
      @$el = $(@render()).appendTo("#popup-layout")
      @$("#main-modal").modal()
      @$("#main-modal").on "hidden", () =>
        @close()

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
    @unmodal()

class ShopProductPreview extends Backbone.View

  events:
    "click .shop_product .preview"    : "launchShopProduct",
    "click .shop_product .buy"        : "launchShopProduct",
    #"click .shop_product .buy"        : "buy"

  initialize: (options) ->
    _.extend(@, options)

  launchShopProduct: (event) ->
    @load_view(event.currentTarget)
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
    @$el = @el = $(target).parents(".shop_product")
    @model = new ShopProductModel({id: @el.attr('shop-product-id')})
    @delegateEvents()

class ShopProductToolbar extends Backbone.View
  events:
    "click .toolbar .buy" : "buy"
    "click .toolbar .cart": "cart"

  initialize: () ->
    @$el = $(@el)
    @login = @options.login
    @shop_product_id = @$el.attr("data-value-id")
    @amount = @$("input.amount")
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
        window.location.href = "/people/#{@login}/direct_transactions"
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

class ShopProductList extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @load_product_view()
    @load_preview()
    @bind_follow()
    $(window).bind("reset_search", _.bind(@search, @))


  load_product_view: () ->
    @load_product = new LoadShopProducts({
      params: {
        fetch_url: "/shop_products/#{@shop.id}/search"
      }
      el: @$('.shop_products_panel')
    })

  load_preview: () ->
    new ShopProductPreview({
      el: @$("#shop_products")
    })

  bind_follow: () ->
    new FollowView({
      data: {
        follow_id: @shop.id,
        follow_type: "Shop"
      },
      login: @user.login,
      el: @$(".shop_info")
    })

  search: (e, query) ->
    @load_product.reset_fetch(query.title)


root.ShopProductView = ShopProductView
root.ShopProductPreview = ShopProductPreview
root.ShopProductToolbar = ShopProductToolbar
root.ShopProductList = ShopProductList
