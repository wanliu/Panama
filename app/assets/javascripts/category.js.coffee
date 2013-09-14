#= require panama
#= require social_sidebar
#= require shop_products
#= require lib/infinite_scroll

root = window || @

class LoadCategoryProducts extends InfiniteScrollView
	msg_el: ".load_msg",
	sp_el: "#category_products"

	add_one: (c) ->
		# c.img_url = c.attachments[0].url
		template = Hogan.compile($("#category_product-preview-template").text())
		@min_column_el().append(template.render(c))
		new ShopProductPreview({
			el: $("[category-product-id=#{c.id}]"),
			model: new ShopProductModel(id: c.id),
			product_id: c.product_id
		})


root.LoadCategoryProducts = LoadCategoryProducts
