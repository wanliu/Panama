#= require jquery
#= require backbone
#= require lib/XPath

class ElementModel extends Backbone.Model

	constructor: (@el, @paths, @options) ->
		super @options
		el = $(@el)[0];
		@parseXPaths(el)


	parseXPaths: (parent, paths = @paths) ->
		for name, query of paths
			results = document.evaluate(
				".//#{query}",
				parent,
				null,
				""
				null)

			if results.value
				for element in results.value
					@set name, $.trim(element.innerText)

