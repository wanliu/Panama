#= require panama
#= require social_sidebar
#= require shop_products
#= require lib/infinite_scroll
#= require following

root = window || @

class LoadShopProducts extends InfiniteScrollView
  params: {
    msg_el: ".scroll-load-msg",
    sp_el: "#shop_products"
  }

  initialize: (options) ->
    _.extend(@params, options.params)
    super @params
    @fetch()

  add_one: (c) ->
    template = Hogan.compile($("#shop_products-preview-template").html())
    @min_column_el().append(template.render(c))


root.LoadShopProducts = LoadShopProducts
