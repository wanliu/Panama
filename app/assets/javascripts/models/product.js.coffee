# author : huxinghai

define(["jquery", "backbone", "exports"], ($, Backbone, exports) ->

	class Product extends Backbone.Model
		urlRoot : ""

	class ProductList extends Backbone.Collection
		model : Product

	exports.Product = Product
	exports.ProductList = ProductList
	
	exports
)