#= require panama
#= require social_sidebar
#= require shop_products
#= require lib/infinite_scroll
#= require catalog

root = window || @

class LoadCategoryProducts extends InfiniteScrollView
	msg_el: ".scroll-load-msg",
	sp_el: "#category_products"

	add_one: (c) ->

		template = Hogan.compile($("#category_product-preview-template").html())
		@min_column_el().append(template.render(c))


root.LoadCategoryProducts = LoadCategoryProducts
