#= require panama
#= require social_sidebar

root = window || @

class LoadCategoryProducts extends Backbone.View
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
			url: "/category/#{@category_id}/category_products",
			success: (data) =>
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
			c.img_url = c.attachments[0].url
			@min_column_el().append(@template.render(c))
			# new CategoryProductPreview({
			#   el: $("[Category-product-id=#{c.id}]"),
			#   model: new CategoryProductModel(id: c.id),
			#   product_id: c.product_id
			# });

	scroll_load: () ->
		sp = @sp_el()
		sp_height = sp.offset().top + sp.height()
		w_height = $(window).height() + $(window).scrollTop()
		if sp_height <= w_height
			clearTimeout(@timeout_id) if @timeout_id
			@timeout_id = setTimeout _.bind(@fetch, @), 250

	sp_el: () ->
		@el.find("#category_products")


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


class CycleIter
  constructor: (@data, @pos = 0) ->

  next: () ->
    @pos = 0 unless @pos < @data.length
    @data[@pos++]


class CategoryProductsView extends Backbone.View

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
    new_dom = $("<div id='category_products'/>")
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


root.CategoryProductsView = CategoryProductsView
root.LoadCategoryProducts = LoadCategoryProducts
