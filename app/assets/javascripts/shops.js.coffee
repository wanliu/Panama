#= require panama
#= require social_sidebar
#= require shop_products

root = window || @

class ShopProductModel extends Backbone.Model

	urlRoot: '/shop_products'


class ShopProductView extends Backbone.View

	events:
		"click [data-dismiss=modal]": "close"

	initialize: (options) ->
		_.extend(@, options)
		backdrop = "<div class='model-popup-backdrop in' />"

		@loadTemplate () =>
			@$backdrop ||= $(backdrop).appendTo("#popup-layout")
			@$el = $(@render()).appendTo(@$backdrop)
			$(window).scroll()
		super

	loadTemplate: (handle) ->
		$.get @model.url() + ".dialog", (data) =>
			@template = data
			handle.call(@)
			@delegateEvents()
			#$.get "/products/#{@product_id}?layout=false", (data) =>
			#	$(".main-show").html(data)

	render: () ->
		tpl = Hogan.compile(@template)
		tpl.render(@model.attributes)

	modal: () ->
		$("body").addClass("noScroll")

	unmodal: () ->
		$("body").removeClass("noScroll")

	close: () ->
		@$backdrop.remove()
		@unmodal()


class ShopProductPreview extends Backbone.View

	events:
		"click .preview" 		: "launchShopProduct"

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

root.ShopProductView = ShopProductView
root.ShopProductModel = ShopProductModel
root.ShopProductPreview = ShopProductPreview