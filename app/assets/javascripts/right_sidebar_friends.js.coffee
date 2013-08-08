root = (window || @)

class FriendsContainerView extends ContainerView
	fill_header: () ->
		$(@el).prepend(
    '<h5 class="tab-header">
			<i class="icon-group"></i> 我关注的
		</h5>')
		@fill_modal()

	bind_items: () ->
		@collection = new Backbone.Collection(url: "/users")
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@collection.fetch(url: "/users/followings")

	addAll: (collecton) ->
		@$(".users-list").html('')
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		friend_view = new FriendView({ model: model, parent_view: @ })
		@$(".users-list").prepend(friend_view.render().el)

	fill_modal: () ->
		$('body').append(@talking_message_modal)

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

class FriendView extends Backbone.View
	tagName: 'li'

	events:
		"click" : "talk_to_friend"

	render: () ->
		html = @template(model: @model)
		$(@el).html(html)
		$(@el).append(@talking_message_modal)
		@

	talk_to_friend: () ->
		# $(".modal").modal('hide')
		# @$(".modal").modal('show')
		# @options.parent_view.$(".modal").modal('show')
		$('.modal.message-talk-box').modal('show')

	template: _.template(
    "<img src='/default_img/t5050_default_avatar.jpg' class='pull-left img-circle' />
    <div class='user-info'>
      <div class='name'><a href='#''><%= model.get('name') %></a></div>
        <div class='type'><%= model.get('follow_type') %></div>
    </div>")

root.FriendsContainerView = FriendsContainerView