#= require jquery
#= require backbone

exports = window || @

class AttributeModel extends Backbone.Model

	constructor: (el, @options) ->
		super(@options)

		for item in el.attributes
			@set(item.name, item.value)


exports.AttributeModel = AttributeModel