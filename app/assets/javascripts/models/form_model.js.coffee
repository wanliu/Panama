#= require jquery
#= require backbone

exports = window || @

class AbstractFormModel extends Backbone.Model

	constructor: (@el, @options) ->
		super(@options)


	fetchAttributes: (el) ->
		attributes = {}
		$(el).find(":input").each (i, input) =>
			name = $(input).attr "name"
			value = $(input).attr "value"
			attributes[name] = value
		attributes

	to_hash: () ->
		@attributes

class FormModel extends AbstractFormModel

	constructor: (@el, @options) ->
		@set @fetchAttributes(@el)
		super @options

class ObjectFormModel extends AbstractFormModel

	PAPAMS_NAME_REGEXP = /(\w+)\[(\w+)\]/

	constructor: (@el, @objectName, @options) ->
		super @el, @options

		attributes = @fetchAttributes @el
		@cleanupMember attributes

	cleanupMember: (attributes) ->

		for attr_name, value of attributes
			field_name = @filterName attr_name
			if field_name?
				@set field_name, value
			else
				@trigger('cleanup_member', @, {name : attr_name, value: value})

	filterName: (name) ->
		if PAPAMS_NAME_REGEXP.test name
			m = name.match(PAPAMS_NAME_REGEXP)
			object_name = m[1]
			if object_name == @objectName
				m[2]

	to_hash: () ->
		results = {}
		for attr, value of @attributes
			name = "#{@objectName}[#{attr}]"
			results[name] = value
		results

exports.AbstractFormModel = AbstractFormModel
exports.FormModel = FormModel
exports.ObjectFormModel = ObjectFormModel
exports