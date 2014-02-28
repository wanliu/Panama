
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
      @modal()
      @$("#main-modal").on "hidden", () => @close()
      @$("#main-modal").on "shown", () => @fetch_state()

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
    @$("#main-modal").modal()
    $("body").addClass("noScroll")    

  unmodal: () ->
    $("body").removeClass("noScroll")
    @setState(true)

  close: () ->    
    @remove()
    @unmodal()

  fetch_state: () ->
    @setState(true)

class ShopProductPreview extends Backbone.View
  fetchState: true

  events:
    "click .shop_product .preview"    : "launchShopProduct",
    "click .shop_product .buy"        : "launchShopProduct"

  initialize: (options) ->
    _.extend(@, options)

  launchShopProduct: (event) ->
    @load_view(event.currentTarget)
    if @fetchState
      @fetchState = false
      @view = new ShopProductView({
        el: @$el,
        model: @model,
        setState: _.bind(@setFetchState, @)
      }) 
      @view.modal()

    false

  load_view: (target) ->
    @$el = @el = $(target).parents(".shop_product")
    @model = new ShopProductModel({id: @el.attr('shop-product-id')})
    @delegateEvents()

  setFetchState: (state) ->
    @fetchState = state

class ShopProductToolbar extends Backbone.View
  events:
    "click .toolbar .buy" : "buy"
    "click .toolbar .cart": "cart"

  initialize: () ->
    @$el = $(@el)
    @login = @options.login
    @shop_product_id = @$el.attr("data-value-id")
    @amount = @$("input.amount")
    @$cart_el = @$(".toolbar .cart")
    @$buy_el = @$(".toolbar .buy")

  buy: () ->
    state = @buy_manner()
    if state == "guarantee"
      @create_order()
    else
      @create_direct_buy()

  create_order: () ->
    if @$buy_el.hasClass("disabled")
      pnotify(text: "这商品不能购买,可能没有库存!", type: "warning")
    else    
      $.ajax(
        url: "/shop_products/#{@shop_product_id}/buy",
        type: "POST",
        data: {amount: @amount.val()}
        dataType: 'JSON'
        success: (data) =>
          window.location.href = "/people/#{@login}/transactions#open/#{data.id}/order"
        error: (data) ->
          pnotify({text: JSON.parse(data.responseText).join("<br />"), title: "出错了！", type: "error"})
      )

  create_direct_buy: () ->
    if @$buy_el.hasClass("disabled")
      pnotify(text: "这商品不能购买,可能没有库存!", type: "warning")
    else
      $.ajax(
        url: "/shop_products/#{@shop_product_id}/direct_buy",
        type: "POST",
        data: {amount: @amount.val()}
        dataType: "JSON",
        success: (data) =>
          window.location.href = "/people/#{@login}/direct_transactions#open/#{data.id}/direct"
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
