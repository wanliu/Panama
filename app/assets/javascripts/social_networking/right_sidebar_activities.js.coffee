root = (window || @)

class ActivitiesContainerView extends ContainerView
	fill_header: () ->
		$(@el).prepend('<h5 class="tab-header"><i class="icon-star"></i>活动消息列表</h5>')

	bind_items: () ->
		# @colleciton = new root.FriendCollection()
		@collection = new Backbone.Collection()
		@collection.bind('reset', @addAll, @)
		@collection.bind('add', @addOne, @)
		@collection.reset([{name: "6666", inline: true}, {name: "8888", inline: true}])
		# @collection.fetch()

	addAll: (collecton) ->
		@$(".activities-list").html('')
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		activity_view = new ActivityView({model: model})
		@$(".activities-list").append(activity_view.render().el)


class ActivityView extends Backbone.View
	tagName: 'li'
	template: (options) ->
		html = $("#right-sidebar-templates .activity-item").html()
		html = html.replace('&lt;', '<').replace('&gt', '>')
		_.template(html)(options)

	# initialize: () ->

	render: () ->
		html = @template(model: @model)
		$(@el).html(html)
		@

root.ActivitiesContainerView = ActivitiesContainerView