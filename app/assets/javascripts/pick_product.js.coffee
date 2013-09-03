root = window || @

class root.WizardView extends Backbone.View

	events:
		"click .leaf_node"       : "get_category_products"
		"click .add_to_shop"     : "add_to_shop"
		"click .remove_from_shop": "remove_from_shop"
		"click .product_list>li" : "select_many"
		"click .select_all"      : "select_all"

	get_category_products: (event) ->
		shop_id = @options.shop_id
		@url = $(event.target).attr("href") + "/products"
		category_product_template = "<option id='{{ id }}' value='{{id}}'>{{ name }}</option>"
		template = @options['category_product_template'] || category_product_template
		@category_product_tpl ||= Hogan.compile(template)
		debugger

		$.ajax({
			type: "get",
			url: @url,
			dataType: "json",
			data:{ shop_id : shop_id },
			success: (data) =>
				category_product_list = ".category_product_list"
				$(category_product_list).empty()
				_.each(data, (product) =>
					$(category_product_list).append(@category_product_tpl.render(product))
				)
		})
		false

	render_product_infor: (product_ids) =>
		$.ajax({
			type: "post",
			url: "/shop_products",
			data: {product_ids: product_ids },
			dataType: "json",
			success: (products) =>
				@options.select_handle(products)
		})
		false

	add_to_shop: () ->
		product_ids = []
		$(".checked_product").each () ->
			product_ids.push($(this).attr("id"))
			$(this).remove()
		@render_product_infor(product_ids)


	select_many : (event) ->
		el = $(event.currentTarget)
		if el.hasClass('checked_product')
			el.removeClass("checked_product")  
		else
			el.addClass("checked_product")

	select_all : ()->
		if $(".select_all").text() == "全选"
			$(".category_product_list .product_item").each(()->
				if !$(this).hasClass("checked_product")
					$(this).addClass("checked_product")
			)
			$(".select_all").text("取消")
		else
			$(".category_product_list .product_item").each(()->
				if $(this).hasClass("checked_product")
					$(this).removeClass("checked_product")
			)
			$(".select_all").text("全选")

	remove_from_shop: ()->
		shop_id = @options.shop_id
		product_ids = []
		$(".my_product_list .checked_product").each ()->
			product_ids.push($(this).attr("id"))
			$(this).remove()
		# @render_product_infor(product_ids)

		$.ajax({
			type: "post",
			data:{product_ids: product_ids}
			url: "/shop_products/#{shop_id}/delete_many",
			dataType: "json",
			success: () ->
				# alert("成功喔，亲")
		})


class root.ProductView extends Backbone.View
	tr_template: "
		<tr id='{{id}}>
			<td><input type='checkbox'></td>
			<td class='name'>{{ name }} </td>
			<td class='price edit'> {{ price }}</td>
			<td class='inventory edit'> {{ inventory }}</td>
			<td><a href='#' class='delete_product'>删除</a></td>
		</tr>"

	initialize: (@options) ->
		@products = @options['models']
		template = @options['template'] || @tr_template
		@template = Hogan.compile(template)

		_.each @products, (model) =>
			@render(model)

	render: (product) ->
		pr = @template.render(product) # product_result
		$(@el).append(pr)
