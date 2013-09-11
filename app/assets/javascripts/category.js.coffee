#= require panama
#= require social_sidebar
#= require lib/infinite_scroll

root = window || @

class LoadCategoryProducts extends InfiniteScrollView
	msg_el: ".load_msg",
	sp_el: "#category_products"

	add_column: (c) ->
		c.img_url = c.attachments[0].url
		# new CategoryProductPreview({
		#   el: $("[category-product-id=#{c.id}]"),
		#   model: new CategoryProductModel(id: c.id),
		#   product_id: c.product_id
		# })


class CategoryProductPreview extends Backbone.View

	events:
		"click .preview"    : "launchCategoryProduct"

	initialize: (options) ->
		_.extend(@, options)

	launchCategoryProduct: (event) ->
		@model.fetch success: (model) =>
			view = new CategoryProductView({
				el         : @$el,
				model      : @model,
				product_id : @product_id
			})
			view.modal()
		false


class CategoryProductModel extends Backbone.Model

	urlRoot: '/category/#{@id}'


root.LoadCategoryProducts = LoadCategoryProducts
