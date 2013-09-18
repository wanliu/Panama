#= require panama
#= require social_sidebar
#= require shop_products
#= require lib/infinite_scroll

root = window || @

class LoadShopProducts extends InfiniteScrollView
	msg_el: ".scroll-load-msg",
	sp_el: "#shop_products",
	fetch_url: "/shop_products"

	add_one: (c) ->
		template = Hogan.compile($("#shop_products-preview-template").text())
		@min_column_el().append(template.render(c))
		new ShopProductPreview({
			el: $("[shop-product-id=#{c.id}]"),
			model: new ShopProductModel(id: c.id),
			product_id: c.product_id
		})


root.LoadShopProducts = LoadShopProducts
