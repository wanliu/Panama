define ['jquery', 'backbone', 'exports'], ($, Backbone, exports) ->

	class CacheTemplate 


	class AbstractResourceView extends Backbone.View

		constructor: (@options) ->
			@urlRoot ||= @options['urlRoot']
			throw "Must set url params" unless @urlRoot?

			@model = @options['model'] || new Backbone.Model
			super(@options)

		render: (state) ->
			data = @fetchView('state')
			$(@el).replaceWith(data)
			@

		fetchView: (state) ->
			url = @stateUrl(state)
			data = jqxhr = status = null

			$.ajax({
				url: url
				async: false
				data: {ajaxify: true}
				success: (_jqxhr, _data, _status) -> 
					jqxhr = _jqxhr
					data = _data
					status = _status
				})

		setRootUrl: (@urlRoot) ->

		getState: () ->

		stateUrl: (state) ->
			switch state
				when 'new', 'create'
					@urlRoot
				when 'edit', 'show'
					paths = @urlRoot.split('/')
					paths.push(@model.get("id"), state)
					paths.join('/')
				when 'update', 'destroy'
					paths = @urlRoot.split('/')
					paths.push(@model.get("id"))
					paths.join('/')


	class ResourceView extends AbstractResourceView

	
	exports.ResourceView = ResourceView
	exports

