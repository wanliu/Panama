define ['jquery', 'backbone'], ($, Backbone) ->

	class AttributeModel extends Backbone.Model

		constructor: (el, @options) ->
			super(@options)
			
			for item in el.attributes
				@set(item.name, item.value)


