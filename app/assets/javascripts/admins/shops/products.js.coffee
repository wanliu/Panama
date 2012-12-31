# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

define [
	'jquery', 
	'backbone', 
	'admins/shops/categories',
	'rails.view', 
	'models/element_model',
	'lib/spin'
	'exports'], ($, Backbone, Category, Rails, ElementModel, Spinner, exports) ->

	class CategoryMiniRow extends Category.AbstractRow
	
		events:
			"click .category"               : "toggleChildren"
			"click .list_category_products" : "getCategoryProducts"

		toggleChildren: (event) ->
			$toggleBtn = $(@el).find(".category")
			state = $toggleBtn.attr('state') == 'true'

			for tr in @getChildren()
				if (state) then $(tr).slideUp() else $(tr).slideDown()
			state = !state;
			$toggleBtn.attr 'state', state

		getCategoryProducts: (event) ->
			url = "#{@options['urlRoot']}/category/#{@model.get("id")}?ajaxify=true"
			btn = @$('.list_category_products')
			icon = btn.find("i")

			opts = {
			  lines: 13, # The number of lines to draw
			  length: 3, # The length of each line
			  width: 2, # The line thickness
			  radius: 5, # The radius of the inner circle
			  corners: 1, # Corner roundness (0..1)
			  rotate: 0, # The rotation offset
			  color: '#000', # #rgb or #rrggbb
			  speed: 1, # Rounds per second
			  trail: 60, # Afterglow percentage
			  shadow: false, # Whether to render a shadow
			  hwaccel: false, # Whether to use hardware acceleration
			  className: 'spinner', # The CSS class to assign to the spinner
			  zIndex: 2e9, # The z-index (defaults to 2000000000)
			  top: 'auto', # Top position relative to parent in px
			  left: 'auto' # Left position relative to parent in px
			}
			target = $("<i class=icon-space></i>").get(0);
			btn.html(target)
			spinner = new Spinner(opts).spin(target)
			$("#table").load url, () -> 
				btn.html(icon)


	class ProductRow extends Rails.ResourceView
		tagName: "tr"

		events: 
			"click .edit"		: "editProduct"
			"click .delete"		: "removeProduct"
			"submitted form"	: "createdProduct"
			"click .update"		: "updateProduct"
			"click .cancel"		: "closeProductEditor"

		no_implementation: () ->
			alert "no implementation!"

		newProduct: () ->
			$("#table table").append(@render('new').el)

		editProduct: () ->
			@render('edit')

		removeProduct: () ->
			@destroy()
			false

		createdProduct: (event, data, model) ->
			$(@el).html(data)
			model = new ElementModel(@el, {
				name: "td[1]", 
				price: "td[2]",
				id: "td[6]"
			})
			@model.set(model.attributes)

		closeProductEditor: () ->
			@render('show')

		updateProduct: () ->
			@no_implementation()

	exports.CategoryMiniRow = CategoryMiniRow
	exports.ProductRow = ProductRow
	exports