
root  = window || @

class  NotificationView extends Backbone.View

	initialize: () ->
		_.extend(@, @options)
		@urlRoot = "/people/#{@current_user_login}/notifications"
		@collection = new Backbone.Collection()
		@transactions_contain_view = new TransactionContainer(parent_view: @)
		@activitys_contain_view = new ActivityContainer(parent_view: @)
		@collection.bind('reset', @add_all, @)
		@collection.fetch(url: "#{@urlRoot}/unreads")
		window.clients.subscribe('/notifications', (data) =>
			console.log('/notifications -->' + data)
		)

	add_all: () ->
		$("#notification_count").text(@collection.length)
		@collection.each (model) =>
			info = model.attributes
			if model.attributes.targeable_type == "Activity"
				@activitys_contain_view.collection.add(model)
			else
				@transactions_contain_view.collection.add(model)
				

class TransactionContainer extends Backbone.View

	initialize: () ->
		el = @options.parent_view.el
		@collection = new Backbone.Collection()
		@collection.bind('add', @add_one, @)

	add_one: (model) ->
		@transactions_view = new TransactionView({
			parent_el: @,
			model: model.attributes
		})
		$(@options.parent_view.el).find(".notifications").append(@transactions_view.render(model.toJSON()))


class TransactionView extends Backbone.View
	tagName: "li"
	className: "transactions_li"

	events: 
		"click" : "direct_to_transaction_detail"

	template: 
		"<a href='{{ url }}'>
			<span class='label label-warning'><i class='icon-info-sign'></i></span>
			{{ body }}
		</a>"

	render: (model) ->
		$(@el).html(Hogan.compile(@template).render(model))

	direct_to_transaction_detail: () ->
		url = @options.parent_el.options.parent_view.urlRoot
		$.ajax({
			type: "POST",
			dataType: "json",
			url: "#{ url }/#{ @model.id }/mark_as_read",
			success: () =>
				window.location.replace(@model.get('url'))
		})


class ActivityContainer extends Backbone.View

	initialize: () ->
		@el = @options.parent_view.el
		@collection = new Backbone.Collection()
		@collection.bind('add', @add_one, @)

	add_one: (model) ->
		@transactions_view = new ActivityViews({
			model: model.attributes,
			parent_view: @
		})
		$(@el).find(".notifications").append(@transactions_view.render(model.toJSON()))

	remove_one: (id, el) ->
		model = @collection.get(id)
		@collection.remove model if model?
		$("#notification_count").html($("#notification_count").text() - 1)
		el.remove()


class ActivityViews extends Backbone.View
	tagName: "li"
	className: "activitys_li"

	events:
		"click " : "show_modal"

	template: 
		"<a href='#'>
			<span class='label label-success'><i class='icon-bell-alt'></i></span>
			{{ body }}
		</a>"

	initialize: () ->
		_.extend(@, @options)

	show_modal: () ->
		activity_model = new ActivityModel({ 
			id: @model.targeable_id 
		})
		
		activity_model.fetch success: (model) =>
			new ActivityView({
				model: model,
				el: $("#popup-layout")
			}).modal()
		@remove()
		false

	render: (model) ->
		$(@el).html(Hogan.compile(@template).render(model))

	remove: () ->
		url = @parent_view.options.parent_view.urlRoot
		$.ajax(
			type: "POST",
			dataType: "json",
			url: "#{ url }/#{ @model.id }/mark_as_read",
			success: () =>
				@parent_view.remove_one(@model.id,@el)
		)


root.NotificationView = NotificationView