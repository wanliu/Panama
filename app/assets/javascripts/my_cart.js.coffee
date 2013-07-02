
root = window || @

class HoverManager

	default_options = {
		timeOut: 1500
	}

	constructor: (@over_elements, @options) ->
		@hover = false

	signalProcess: (event) ->
		_(@over_elements).include(event.currentTarget)


	checkStatus: (event) ->

class MyCart extends Backbone.View
	# el: "#my_cart"
	el: $('#my_cart')

	events:
		"click .handle": "toggleCartBox"

	item_row: """
		<tr id= "product_item{{id}}">
			<td><img src="{{icon}}" ></td>
			<td><span class="title" data-toggle="tooltip" title="{{title}}">{{title}}</span></td>
			<td>{{amount}}</td>
			<td class="row">{{total}}</td>
		</tr>
	"""

	initialize: (@options) ->
		@hm = new HoverManager(@$("a.handle, #cart_box"))
		debugger
		@totals_money()


	toggleCartBox: (event) ->
		$("#cart_box")
			.toggle () ->
				if $(@).hasClass "fadeInUpBig"
					'animate fadeInDownBig show'
				else
					'animate fadeInUpBig'
		false

	hoverProcess: (event) ->
		@$("#cart_box")
			.show()
			.addClass("animated fadeInUpBig")
		# @hm.signalProcess(event)

	blurProcess: (event)->
		$(@el)
			.addClass("animated fadeInDownBig")

	addToCart: ($element, form, urlAction) ->
		$el = $(@el)

		targetPosition = @targetAttributes($el)
		pos = $element.offset()
		moveTarget = $element
			.clone()
			.addClass("moving")
			.appendTo("body")

		moveTarget
			.css('position', "fixed")
			.css('top', pos.top - $(window).scrollTop())
			.css('left', pos.left - $(window).scrollLeft())
			.animate targetPosition, () =>
				$(@el).addClass("bounce")
				moveTarget.remove()
				@cartAddAction(urlAction, form)

	cartAddAction: (url, form) ->
		$.post url, form.serialize(), (item) =>
			if  $("#product_item#{item.id}").length > 0
				trObj = $("#product_item#{item.id}")
				trObj.replaceWith(@trHtml(item))
				# $(trOjb[2]).html(item.amount)
				# $(trOjb[3]).html(item.total)
			else
				$(".cart_main").append(@trHtml(item))
				$("#shop_count").html($(".cart_main tr").size())
				$("#cart_box .checkout").removeClass("disabled")
				@$("#shop_count").html($(".cart_main tr").size())
			@totals_money()
			# $(".cart_main tr").each () ->
			# 	totals += parseFloat($(this).find(".row").html())
			# $(".cart_bottom tr td").html("商品总价：" + totals)
			# totals = $(".product_total span").text(parseFloat(totals))

	totals_money: () ->
		totals = 0.0
		$(".cart_main tr").each () ->
				totals += parseFloat($(this).find(".row").html())
			$(".cart_bottom tr td").html("商品总价：" + totals)


	trHtml: (product_item) ->
		row_tpl = Hogan.compile(@item_row)
		row_tpl.render(product_item)

	targetAttributes: (target) ->
		top: target.offset().top - $(window).scrollTop()
		left: target.offset().left - $(window).scrollLeft()
		width: target.width()
		height: target.height()
		opacity: 0.25

class CartBox extends Backbone.View

myCart = new MyCart

$("[add-to-cart]").on "click", (event) ->
	$form     = $(@).parents("form")
	selector  = $(@).attr('add-to-cart')
	urlAction = $(@).attr('add-to-action')

	myCart.addToCart($(selector), $form, urlAction)
	false

root.myCart = myCart
root
