#= require panama
#= require social_sidebar
#= require shop_products
#= require lib/infinite_scroll

root = window || @

class ShopProductModel extends Backbone.Model

	urlRoot: '/shop_products'


class ShopProductView extends Backbone.View

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


class ShopProductPreview extends Backbone.View

	events:
		"click .preview"    : "launchShopProduct"

	initialize: (options) ->
		_.extend(@, options)

	launchShopProduct: (event) ->
		@model.fetch success: (model) =>
			view = new ShopProductView({
				el         : @$el,
				model      : @model,
				product_id : @product_id
			})
			view.modal()
		false


class LoadShopProducts extends InfiniteScrollView
	msg_el: ".load_msg",
	sp_el: "#shop_products",
	fetch_url: "/shop_products"

	add_column: (c) ->
		new ShopProductPreview({
			el: $("[shop-product-id=#{c.id}]"),
			model: new ShopProductModel(id: c.id),
			product_id: c.product_id
		})


root.ShopProductModel = ShopProductModel
root.ShopProductView = ShopProductView
root.ShopProductPreview = ShopProductPreview
root.LoadShopProducts = LoadShopProducts
