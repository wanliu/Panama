define ['jquery', 'backbone', 'exports',"lib/hogan"] , ($, Backbone, exports) ->

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
				if $("#cart_box table #product_item#{item.product_item.id}").length > 0
					trOjb = $("#cart_box table #product_item#{item.product_item.id} td")
					$(trOjb[2]).html(item.product_item.amount)
					$(trOjb[3]).html(item.product_item.total)
				else
					$(".cart_main").append(@trHtml(item.product_item))
				
				$("#shop_count").html($(".cart_main tr").size())

		trHtml: (product_item) ->
			strHmtl = "<tr id= 'product_item#{product_item.id}'>"
			strHmtl += "<td><img src='#{product_item.img}''></td>"
			strHmtl += "<td>#{product_item.title}</td>"
			strHmtl += "<td>#{product_item.amount}</td>"
			strHmtl += "<td>#{product_item.total}</td></tr>"
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

		sub_id = form.find('#product_item_sub_product_id').val()
		if sub_id
			myCart.addToCart($(selector), form, urlAction)
		else
			alert("请选择样式！")

	exports.myCart = myCart
	exports
