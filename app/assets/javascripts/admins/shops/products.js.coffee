# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery
#= require jquery-ui
#= require backbone
#= require admins/shops/categories
#= require rails.view
#= require models/element_model
#= require lib/spin

root = window || @

class CategoryMiniRow extends AbstractRow

	events:
		"click .category"               : "toggleChildren"
		"click .list_category_products" : "getCategoryProducts"

	droppable: {
		activeClass: "ui-state-hover"
		hoverClass: "ui-state-active"
		accept: "#table table tr"
	}

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

	moveToCategory: (product) ->
		url = "#{@options['urlRoot']}/category/#{@model.get("id")}/accept/#{product.get('id')}"

		$.post(url)

	onDroppable: (event, ui) ->
		ui.draggable.draggable({revert: 'invalid'})
		product = new ElementModel(ui.draggable, {
			name: "td[1]",
			price: "td[2]",
			id: "td[6]"
		})
		@moveToCategory(product)
		ui.draggable
			.slideUp () ->
				$(@).remove()

class ProductRow extends ResourceView
	tagName: "tr"

	events:
		"click .edit"		: "editProduct"
		"click .delete"		: "removeProduct"
		"submitted form"	: "createdProduct"
		"click .update"		: "updateProduct"
		"click .close"		: "closeProductEditor"
		"click .cancel"		: "cancelEditor"

	draggable: {
		revert: true
		helper: "clone"
	}

	no_implementation: () ->
		alert "no implementation!"

	newProduct: () ->
		$("#table table").append(@render('new').el)
		@$('#product_category_id').chosen().change(_.bind(@changeAdditionProperties, @))

	editProduct: () ->
		@render('edit')
		@$('#product_category_id').chosen().change(_.bind(@changeAdditionProperties, @))

	removeProduct: () ->
		@destroy()
		false

	changeAdditionProperties: (e) ->
		category_id = $(e.target).val()
		product_id = @$("#product_id").text()


		url = "#{@urlRoot}/additional_properties/#{category_id}?product_id=#{product_id}"

		@$(".additional_properties").load(url)

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

	cancelEditor: () ->
		@remove()

	updateProduct: () ->
		@no_implementation()

root.CategoryMiniRow = CategoryMiniRow
root.ProductRow = ProductRow
