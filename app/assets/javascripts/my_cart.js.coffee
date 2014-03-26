
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
	el: $('.shoppingcart')

	events:
		"click .shoppingcart": "toggleCartBox"
		"click .clear_list"  : "clear_list"

	item_row: 
		'<tr id="product_item{{id}}" class="cart_main">
			<td><img src="{{icon}}" ></td>
			<td>
				<span class="title" data-toggle="tooltip" title="{{title}}">
					{{title}}
				</span>
			</td>
			<td>{{amount}}</td>
			<td class="row">{{total}}</td>
		</tr>'

	initialize: (@options) ->
		@hm = new HoverManager($("a.handle, #cart_box"))
		@total_amounts()
		@totals_money()

	toggleCartBox: (event) ->
		$("#cart_box")
			.toggle () ->
				if $(@).hasClass "fadeInUpBig"
					'animate fadeInDownBig show'
				else
					'animate fadeInUpBig'
		false

	clear_list: () ->
		$.ajax({
      type: "post",
      url: "/mycart/clear_list",
      success: () =>
       $(".cart_main").remove()
       $("#shop_count").html($(".cart_main").size()).hide()
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
		@scrollY = window.scrollY
		$el = $("#cart_box")
		targetPosition = @targetAttributes($(".icon-shopping-cart"))
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
		amount = form.serializeHash().product_item.amount
		return pnotify(type: 'error', text: '数量必须为大于0的整数') unless amount > 0 && amount % 1 is 0
		$.post url, form.serialize(), (item) =>
			if $("#product_item#{item.id}").length > 0
				trObj = $("#product_item#{item.id}")
				trObj.replaceWith(@trHtml(item))
			else
				$(".cart_table").append(@trHtml(item))
				$("#cart_box .checkout").removeClass("disabled")
			@total_amounts()
			@totals_money()
			pnotify(title: "系统提醒", text: "加入购物车成功！")
		.fail (data) =>
			try
				messages = JSON.parse(data.responseText)
				pnotify(title: "出错了", text: messages.join(), type: "error")
			catch error
				pnotify(title: "出错了", text: data, type: "error")

		window.scrollTo(0, @scrollY)

	total_amounts: () ->
		trs = @$(".cart_main")
		s = 0
		for e in trs
			s += parseInt($(e).find("td:nth(2)").text())
		if s != 0
			$("#shop_count").html(s).show()
		else
			$("#shop_count").html(s).hide()

	totals_money: () ->
		totals = 0
		$(".cart_main").each (i, e) =>
			totals += parseFloat($(e).find(".row").text())
		$("#cart_box .product_total").html("总计：￥#{totals.toFixed(2)}")

	trHtml: (product_item) ->
		row_tpl = Hogan.compile(@item_row)
		row_tpl.render(product_item)

	targetAttributes: (target) ->
		top: target.offset().top - $(window).scrollTop()
		left: target.offset().left - $(window).scrollLeft()
		width: target.width()
		height: target.height()
		opacity: 0.25


myCart = new MyCart

$ ->
	$("[add-to-cart]").on "click", (event) =>
		$form     = $(@).parents("form")
		selector  = $(@).attr('add-to-cart')
		urlAction = $(@).attr('add-to-action')
		myCart.addToCart($(selector), $form, urlAction)
		false

root.myCart = myCart