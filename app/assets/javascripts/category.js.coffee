#= require panama
#= require social_sidebar
#= require shop_products
#= require lib/infinite_scroll

root = window || @

class LoadCategoryProducts extends InfiniteScrollView
	msg_el: ".load_msg",
	sp_el: "#category_products"

	before_add: (c) ->
		c.img_url = c.attachments[0].url

	add_column: (c) ->
		new CategoryProductPreview({
		  el: $("[category-product-id=#{c.id}]"),
		  model: new CategoryProductModel(id: c.id),
		  product_id: c.product_id
		})


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

	urlRoot: '/shop_products'


class CategoryProductView extends Backbone.View

	events:
		"click [data-dismiss=modal]": "close"

	initialize: (options) ->
		_.extend(@, options)
		@loadTemplate () =>
			@$backdrop = $("<div class='model-popup-backdrop in' />").appendTo("body")
			@$dialog = $("<div class='dialog-panel' />").appendTo("#popup-layout")
			@$el = $(@render()).appendTo(@$dialog)
			$(window).scroll()
		super

	loadTemplate: (handle) ->
		$.get @model.url() + ".dialog", (data) =>
			@template = data
			handle.call(@)
			@delegateEvents()

	render: () ->
		tpl = Hogan.compile(@template)
		tpl.render(@model.attributes)

	modal: () ->
		$("body").addClass("noScroll")

	unmodal: () ->
		$("body").removeClass("noScroll")

	close: () ->
		@$dialog.remove()
		@$backdrop.remove()
		@unmodal()


root.LoadCategoryProducts = LoadCategoryProducts
