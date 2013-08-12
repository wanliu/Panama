#= require lib/realtime_client
root = window || @
class TransactionView extends ContainerView

	template2: "<li><div class='user-info'>你订单{{number}}已经{{state_title}},点击
							<a href='{{url}}'>这里</a>
							 查看详情</div></li>"
	template1: "<li><p><i class=' icon-volume-up'></i>&nbsp;你的订单{{number}}买家已经{{state_title}},点击
	 						<a href='{{url}}'>这里</a>
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
		# @collection = new Backbone.Collection(url: "/notifications")
		# @collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@client = Realtime.client(@realtime_url)
		@client.monitor_people_notification @token, (info) =>	
			@collection.add(info.value)

	# addAll: (collecton) ->
	# 	@collection.each (model) =>
	# 		@addOne(model)

	addOne: (model) ->
		row_item = Hogan.compile(@template1)
		@$('ul').append(row_item.render(model.toJSON()))
		

root.TransactionView = TransactionView