define ['jquery', 'backbone', 'lib/XPath'], ($, Backbone,XPath) ->

	class ElementModel extends Backbone.Model

		constructor: (@el, @paths, @options) ->
			super @options
			el = $(@el)[0];

			@parseXPaths(el)


		parseXPaths: (parent, paths = @paths) ->
			for name, query of paths
				results = document.evaluate(
					query,
					parent,
					null,
					""
					null)

				for element in results.value
					@set name, $.trim(element.innerText)

