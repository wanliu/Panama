root = (window || @)

class ActivitiesContainerView extends ContainerView
	initialize: (options) ->
		_.extend(@, options)
		@notices = new ActivityNoticeList()
		@notices.bind("add", @add_data, @)
		@bind_realtime()
		@urlRoot = "people/z2009zxiaolong/notifications"
		super

	add_data: (model) ->
		view = new ActivityNoticeView(model: model)
		@notice_msg()

	add: (data) ->
		@notices.add(data)

	notice_msg: () ->

	bind_realtime: () ->
		@client = Realtime.client(@realtime_url)
		@client.subscribe "/Activity/un_dispose", (info) =>
			@realtime_help(info, 'activities')

	realtime_help: (info, type) ->
		data = info.values
		switch info.type
			when "new"
				@add(_.extend(data, {_type: type}))


	fill_header: () ->
		$(@el).prepend('<h5 class="tab-header"><i class="icon-star"></i>活动消息列表</h5>')

	bind_items: () ->
		@collection = new Backbone.Collection(url: "/activities")
		@collection.bind('reset', @addAll, @)
		@collection.bind('fetch', @addAll, @)
		@collection.bind('add', @addOne, @)
		@collection.fetch({ url: '#{@urlRoot}/unread?type=Activity' })

	addAll: (collecton) ->
		@$(".activities-list").html('')
		@collection.each (model) =>
			@addOne(model)

	addOne: (model) ->
		activity_view = new ActivityNoticeView({model: model})
		@$(".activities-list").append(activity_view.render().el)


class ActivityNoticeView extends Backbone.View
	tagName: 'li'
	template: (options) ->
		html = $("#right-sidebar-templates .activity-item").html()
		html = html.replace('&lt;', '<').replace('&gt', '>')
		_.template(html)(options)

	events:
		"click" : "show_modal"

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)

	show_modal: () ->
		@model = new ActivityModel({ id: 32 })
		@model.fetch success: (model) =>
			view = new ActivityView({
				model    : model 
			})
			view.modal()

	render: () ->
		html = @template(model: @model)
		$(@el).html(html)
		@


class ActivityNotice extends Backbone.Model
	set_url: (activity_id) ->
		@urlRoot = "activities/#{activity_id}"

	dispose: (callback) ->
		$.ajax(
			url: "#{@urlRoot}/#{@id}/dispose"
			type: "POST",
			success: callback
		)

class ActivityNoticeList extends Backbone.Collection
	model: ActivityNotice


root.ActivitiesContainerView = ActivitiesContainerView