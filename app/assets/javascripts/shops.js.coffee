//= require panama
//= require social_sidebar
//= require lib/jquery.nanoscroller

root = window || @

class ShopProductModel extends Backbone.Model

	urlRoot: '/shop_products'


class ShopProductView extends Backbone.View

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

	render: () ->
		tpl = Hogan.compile(@template)
		tpl.render(@model.attributes)

	modal: () ->
		$("body").addClass("noScroll")


class ShopProductPreview extends Backbone.View

	events:
		"click .preview" 		: "launchShopProduct"

	initialize: (options) ->
		_.extend(@, options)

	launchShopProduct: (event) -> 
		@model.fetch success: (model) =>
			view = new ShopProductView({
				el       : @$el,
				model    : @model 
			})
			view.modal()
		false

root.ShopProductView = ShopProductView
root.ShopProductModel = ShopProductModel
root.ShopProductPreview = ShopProductPreview