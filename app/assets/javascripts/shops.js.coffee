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
			#$.get "/products/#{@product_id}?layout=false", (data) =>
			# $(".main-show").html(data)

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


class CycleIter
	constructor: (@data, @pos = 0) ->

	next: () ->
		@pos = 0 unless @pos < @data.length
		@data[@pos++]


class LoadShopProducts extends Backbone.View
	offset: 0,
	limit: 10,

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)
		@fetch()
		$(window).scroll(_.bind(@scroll_load, @))

	fetch: () ->
		@$el.find(".load_msg").show()
		$.ajax(
			url: "/shop_products",
			data: {
				shop_id: @shop_id,
				offset: @offset,
				limit: @limit
			},
			success: (data) =>
				if data[0] == undefined
				# if data.length < 10 # 小于pageSize
					@$(".load_msg").html('<div class="text-center">亲，已经到底啦</div>')
				else
					@$el.find(".load_msg").hide()
					@add_columns(data)
					@offset += @limit
		)

	min_column_el: () ->
		columns = @sp_el().find(".columns>.column")
		cls = _.map columns, (c) -> $(c).height()
		$(columns[cls.indexOf(_.min(cls))])

	add_columns: (data) ->
		_.each data, (c) =>
			@min_column_el().append(@template.render(c))
			new ShopProductPreview({
				el: $("[shop-product-id=#{c.id}]"),
				model: new ShopProductModel(id: c.id),
				product_id: c.product_id
			})

	scroll_load: () ->
		if $(".load_msg").css("display") != "block"
			sp = @sp_el()
			sp_height = sp.offset().top + sp.height()
			w_height = $(window).height() + $(window).scrollTop()
			if sp_height <= w_height
				clearTimeout(@timeout_id) if @timeout_id
				@timeout_id = setTimeout _.bind(@fetch, @), 250

	sp_el: () ->
		@el.find("#shop_products")


class ShopProductsView extends Backbone.View

	initialize: (@options) ->
		$(window).resize($.proxy(@relayoutColumns, @))
		@relayoutColumns()

	resizeWrap: (e) ->
		@$el.width(@$columns.width())

	adjustNumber: () ->
		$wrap = $('.wrap')
		count = parseInt(($wrap.width() - 25) / 246)

	relayoutColumns: () ->
		shop_products = @fetchResults()
		new_dom = $("<div id='shop_products'/>")
		@$columns = $("<div class='columns' />").appendTo(new_dom)
		@$columns.append("<div class='column' />") for i in [0...@adjustNumber()]

		cycle = new CycleIter(@$columns.find(".column"))

		for act in shop_products
			target = cycle.next()
			$(target).append(act)

		@$el.replaceWith(new_dom)
		@$el = new_dom
		@resizeWrap()

	fetchResults: () ->
		row = 0
		columns = @$(".column")
		results = []
		while _(_(columns).map (elem, i ) ->
			node = $(elem).find(">div")[row]
			results.push(node) if node?
			node).any()
			row++

		results


root.ShopProductView = ShopProductView
root.ShopProductModel = ShopProductModel
root.ShopProductPreview = ShopProductPreview
root.ShopProductsView = ShopProductsView
root.LoadShopProducts = LoadShopProducts