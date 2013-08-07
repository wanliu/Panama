root = window || @

class TransactionNotify extends Backbone.View

	template1: "<li><p>你购买的产品已经{{state}},点击
							<a href='people/#{current_user}/tranactions/#{id}'>这里</a>
							 查看详情<p></li>"
	template2: "<li><p>你的买家{{buyer_name}}已经{{state}},点击
							<a href='people/#{current_user}/tranactions/#{id}'>这里</a>
							 查看详情<p></li>"

	initialize: (@options)->
		_.extend(@, @options)
		

	notify: (model) ->
		if current_user.is_seller?
			$('li').last().after(@template2)
			$@el.css("width",'120%')
		else
			$('li').last().after(@template1)
			$@el.css("width",'120%')