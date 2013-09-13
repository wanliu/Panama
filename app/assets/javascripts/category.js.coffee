#= require panama
#= require social_sidebar
#= require shop_products
#= require lib/infinite_scroll

root = window || @

class LoadCategoryProducts extends InfiniteScrollView
	msg_el: ".load_msg",
	sp_el: "#category_products"

	add_column: (c) ->
		new ShopProductPreview({
		  el: $("[category-product-id=#{c.id}]"),
		  model: new ShopProductModel(id: c.id),
		  product_id: c.product_id
		})


root.LoadCategoryProducts = LoadCategoryProducts
