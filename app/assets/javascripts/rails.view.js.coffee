#= require 'jquery'
#= require 'jquery-ui'
#= require 'lib/dnd'
#= require 'backbone'
#= require 'models/form_model'

root = window || @

class AbstractFormView extends DNDView
	el: "form"

	constructor: (@el, @options) ->
		super(@options)
		$(@el).on 'ajax:before', $.proxy(@prependForm, @)
		$(@el).on 'submit:success', $.proxy(@submitted, @)
		$(@el).on 'submit', $.proxy(@submit, @)

	prependForm: () ->
		input = $(@el).find(":input[name=ajaxify]")
		input = $("<input type=hidden name=ajaxify />").appendTo(@el) unless input.length > 0
		input.val(true)


	submitted: (event, data, status) ->
		$(@el).trigger 'submitted', [data, @model, status]

	submit: () ->
		$(@el).submit(false);

class FormView extends AbstractFormView

class AbstractResourceView extends DNDView

	constructor: (@options) ->
		@urlRoot = @options['urlRoot'] || @urlRoot
		throw "Must set url params" unless @urlRoot?

		@model = @options['model'] || new Backbone.Model
		super(@options)

		@remoteFormProxy()

	render: (state) ->
		data = @fetchView(state)
		@el = $(@el).html(data)
		@remoteFormProxy()
		@

	repalceWith: (state) ->
		data = @fetchView(state)
		$(@el).replaceWith(data)

	form: (form_dom) ->
		new FormView form_dom

	fetchView: (state) ->
		url = @stateUrl(state)
		data = jqxhr = status = null

		$.ajax({
			url: url
			async: false
			data: {ajaxify: true}
			success: (_data, _status, _jqxhr) ->
				jqxhr = _jqxhr
				data = _data
				status = _status
			})
		data

	remoteFormProxy: () ->
		$(@el).find("form[data-remote]").each (i, form) =>
			f = @form(form)

	setRootUrl: (@urlRoot) ->

	getState: () ->

	stateUrl: (state) ->
		switch state
			when 'new'
				@joinPath @urlRoot, 'new'
			when 'create'
				@urlRoot
			when 'edit'
				@joinPath @urlRoot, @model.get("id"), state
			when 'update', 'destroy', 'show'
				@joinPath @urlRoot, @model.get("id")

	joinPath: (path, args...) ->
		paths = path.split '/'
		paths = paths.concat args
		paths.join '/'

	# resource process
	save: (model = @model) ->
		url = @stateUrl('create')
		attributes = model.to_hash()
		attributes["ajaxify"] = true
		$.post url, attributes

	destroy: () ->
		url = @stateUrl('destroy')
		$.post url, { "_method": 'delete'}, () =>
			@remove()

class ResourceView extends AbstractResourceView


root.ResourceView = ResourceView
root.FormView = FormView
root

