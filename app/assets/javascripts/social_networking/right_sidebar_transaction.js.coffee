root = window || @
class TransactionView extends ContainerView

	template2: "<li><div class='user-info'>你购买的产品已经{{state}},点击
							<a href='/people/{{current_user}}/transactions/{{transaction_id}}'>这里</a>
							 查看详情</div></li>"
	template1: "<li><p><i class=' icon-volume-up'></i>&nbsp;你的订单买家已经{{state}},点击
	 						<a href='/shops/{{current_user}}/admins/order_refunds#refund1'>这里</a>
	 						 查看详情<p></li>"

	talking_message_modal: '<div class="modal hide fade message-talk-box">
	  <div class="modal-header">
	    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	    <h3><img src="/default_img/t5050_default_avatar.jpg" />sss</h3>
	  </div>
	  <div class="modal-body">
	    <p>One fine body…</p>
	  </div>
	  <div class="modal-footer">
	    <a href="#" class="btn">Close</a>
	    <a href="#" class="btn btn-primary">Save changes</a>
	  </div>
	</div>'

	fill_header: () ->
		$(@el).prepend(
        '<h5 class="tab-header">
			<i class="icon-edit"></i> 交易消息
		</h5>')
		@fill_modal()
	fill_modal: () ->
		$('body').append(@talking_message_modal)

	


	bind_items: () ->
		@collecton = new Backbone.Collection
		@collecton.bind('add', @addOne, @)
		# @collecton.add({state: "uncomplete", current_user: "xifengzhu",transaction_id: 4})
		@collecton.add({state: "redund", current_user: "SA",refund_id: 1})
		# @collecton.add({state: "completed", current_user: "SA",transaction_id: 2})

	addOne: (model) ->
		row_item = Hogan.compile(@template1)
		@$('ul').append(row_item.render(model.toJSON()))

root.TransactionView = TransactionView