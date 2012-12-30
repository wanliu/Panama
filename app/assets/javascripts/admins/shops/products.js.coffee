# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

define ['jquery', 'backbone', 'admins/shops/categories','rails_view', 'exports'], ($, Backbone, Category, Rails, exports) ->

	class CategoryMiniRow extends Category.AbstractRow
	
		events:
			"click .category"   : "toggleChildren"

		toggleChildren: (event) ->
			$toggleBtn = $(@el).find(".category")
			state = $toggleBtn.attr('state') == 'true'

			for tr in @getChildren()
				if (state) then $(tr).slideUp() else $(tr).slideDown()
			state = !state;
			$toggleBtn.attr 'state', state			

	class ProductRow extends Rails.ResourceView
		urlRoot: "admins/products"

		events: 
			"click .edit"		: "editProduct"
			"click .delete"		: "removeProduct"
			"click .save"		: "createProduct"
			"click .update"		: "updateProduct"

		no_implementation: () ->
			alert "no implementation!"

		newProduct: () ->
			$("#table").append(@render('new').el)

		editProduct: () ->
			render('edit').el
			no_implementation()

		removeProduct: () ->
			no_implementation()

		createProduct: () ->
			no_implementation()

		updateProduct: () ->
			no_implementation()

	exports.CategoryMiniRow = CategoryMiniRow
	exports.ProductRow = ProductRow
	exports