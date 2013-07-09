
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
	el: $('.shoppingcart')

	events:
		"click .handle": "toggleCartBox"
		"click .clear_list": "clear_list"

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
		@totals_money()
		@total_amounts()


	toggleCartBox: (event) ->
		$("#cart_box")
			.toggle () ->
				if $(@).hasClass "fadeInUpBig"
					'animate fadeInDownBig show'
				else
					'animate fadeInUpBig'
		false

	clear_list: () ->
		debugger
		$.ajax({
	      type: "post",
	      url: "/mycart/clear_list",
	      success: () =>
	       $(".cart_main tr").remove()
	       $("#shop_count").html($(".cart_main tr").size())
	       @totals_money()
    	})

	hoverProcess: (event) ->
		$("#cart_box")
			.show()
			.addClass("animated fadeInUpBig")

	blurProcess: (event)->
		$("#cart_box")
			.addClass("animated fadeInDownBig")

	addToCart: ($element, form, urlAction) ->
		$el = $("#cart_box")
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
			else
				$(".cart_main").append(@trHtml(item))
				$("#cart_box .checkout").removeClass("disabled")
			@total_amounts()
			@totals_money()

	total_amounts: () ->
		trs = @$(".cart_main tr")
		s = 0
		for e in trs
			s += parseInt($(e).find("td:nth(2)").text())
		$("#shop_count").html(s)

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

$ ->
	$("[add-to-cart]").on "click", (event) ->
		$form     = $(@).parents("form")
		selector  = $(@).attr('add-to-cart')
		urlAction = $(@).attr('add-to-action')
		myCart.addToCart($(selector), $form, urlAction)
		false

root.myCart = myCart
root
