#= require jquery
#= require backbone
#= require lib/hogan

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
	el: "#my_cart"

	events:
		"click .handle": "toggleCartBox"


	initialize: (@options) ->
		@hm = new HoverManager(@$("a.handle, #cart_box"))


	toggleCartBox: (event) ->
		$("#cart_box")
			.toggle () ->
				if $(@).hasClass "fadeInUpBig"
					'animate fadeInDownBig show'
				else
					'animate fadeInUpBig'

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

		moveTarget = $element
			.clone()
			.appendTo("body")

		moveTarget
			.css('position', "fixed")
			.animate targetPosition, () =>
				$(@el).addClass("bounce")
				moveTarget.remove()
				@cartAddAction(urlAction, form)

	cartAddAction: (url, form) ->
		$.post url, form.serialize(), (item) =>
			if $("#product_item#{item.id}").length > 0
				trOjb = $("#product_item#{item.id} td")
				$(trOjb[2]).html(item.amount)
				$(trOjb[3]).html(item.total)
			else
				$(".cart_main").append(@trHtml(item))

			$("#shop_count").html($(".cart_main tr").size())


			# totals = $(".cart_bottom tr td").html().split("")[5]
			# totals = totals + item.product_item.total
			# alert(totals)
			# $(".cart_bottom tr td").html("商品总价：" + totals)

	trHtml: (item) ->
		strHmtl = "<tr id= 'product_item#{item.id}'>"
		strHmtl += "<td><img src='#{item.img_path}''></td>"
		strHmtl += "<td>#{item.title}</td>"
		strHmtl += "<td>#{item.amount}</td>"
		strHmtl += "<td>#{item.total}</td></tr>"
		strHmtl

	targetAttributes: (target) ->
		top: target.position().top
		left: target.position().left
		width: target.width()
		height: target.height()
		opacity: 0.25


class CartBox extends Backbone.View

myCart = new MyCart

$("[add-to-cart]").on "click", (event) ->
	selector = $(@).attr('add-to-cart')
	urlAction = $(@).attr('add-to-action')
	form = $(@).parents("form")

	myCart.addToCart($(selector), form, urlAction)

root.myCart = myCart
root
