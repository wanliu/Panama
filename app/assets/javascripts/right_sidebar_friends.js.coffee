root = (window || @)

class FriendsContainerView extends ContainerView
	fill_header: () ->
		$(@el).prepend('<h5 class="tab-header"><i class="icon-group"></i> Last logged-in users</h5>')

	bind_items: () ->
		# @colleciton = new root.FriendCollection()
		@collection = new Backbone.Collection()
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@collection.reset([{name: "lixiao", inline: true}, {name: "daidi", inline: true}])
		# @collection.fetch()

	addAll: (collecton) ->
		@$(".users-list").html('')
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		friend_view = new FriendView({model: model})
		@$(".users-list").append(friend_view.render().el)


class FriendView extends Backbone.View
	tagName: 'li'
	template: (options) ->
		html = $("#right-sidebar-templates .sign-item").html()
		html = html.replace('&lt;', '<').replace('&gt', '>')
		_.template(html)(options)

	# initialize: () ->

	render: () ->
		html = @template(model: @model)
		$(@el).html(html)
		@

root.FriendsContainerView = FriendsContainerView