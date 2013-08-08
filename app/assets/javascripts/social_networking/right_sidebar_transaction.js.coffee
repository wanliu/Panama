root = window || @
class TransactionView extends ContainerView

	template1: "<ul><li><p>你购买的产品已经{{state}},点击
							<a href='/people/{{current_user}}/transactions/{{transaction_id}}'>这里</a>
							 查看详情<p></li></ul>"
	template2: "<li><p>你的订单买家已经{{state}},点击
	 						<a href='/shops/{{current_user}}/admins/transactions/{{transaction_id}}'>这里</a>
	 						 查看详情<p></li>"

	bind_items: () ->
		@collecton = new Backbone.Collection
		@collecton.bind('add', @addOne, @)
		# @collecton.add({state: "uncomplete", current_user: "xifengzhu",transaction_id: 4})
		@collecton.add({state: "completed", current_user: "SA",transaction_id: 7})

	addOne: (model) ->
		row_item = Hogan.compile(@template2)
		$(".body.tab-content").append(row_item.render(model.toJSON()))

root.TransactionView = TransactionView