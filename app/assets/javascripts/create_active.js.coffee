define ['jquery', 'backbone', 'twitter/bootstrap'], ($, Backbone) ->

	class CreateActive extends Backbone.View

		template_url: "/activities/new.dialog"

		initialize: (@options) ->
			super
			@on('show', @render, @)
			@waitTemplate(false)
			@render()
			$(@$el).modal(show:false)

		waitTemplate: (async = true) ->
			$.ajax(@template_url, async: async ).success (data, status, xhr) =>
				@template = data

		render: () ->
			@$el.html(@template)
			@

		show: () ->
			$(@$el).modal('show')
