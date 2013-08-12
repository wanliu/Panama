#= require lib/realtime_client
root = window || @
class TransactionView extends ContainerView

	template1: "<li><p><i class=' icon-volume-up'></i>{{body}},点击
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
		@collection = new Backbone.Collection
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@collection.fetch(url: "/people/#{@current_user_login}/notifications")
		@client = Realtime.client(@realtime_url)
		@client.monitor_people_notification @token, (info) =>	
			@collection.add(info.value) if info.type == "OrderTransaction"
			 	

	addAll: (collecton) ->
	 	@collection.each (model) =>
	 		if model.attributes.targeable_type == "OrderTransaction"
	 			@addOne(model)

	addOne: (model) ->
		debugger
		row_item = Hogan.compile(@template1)
		@$('ul').append(row_item.render(model.toJSON()))
		

root.TransactionView = TransactionView