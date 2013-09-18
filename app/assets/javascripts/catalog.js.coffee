# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
root  =  window || @
class CatalogView extends Backbone.View

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)
		@get_catalog()

	template: (model) ->
		_.template("<li><a href='/catalog/<%= model.get('id') %>'><%=model.get('title') %></a></li>")(model)

	get_catalog: () ->
		@collection = new Backbone.Collection()
		@collection.bind("reset", @add_all, @)
		@collection.fetch(url: "/catalog")

	add_all: (models)->
		models.each (model) =>
			@$el.append(@template(model: model))

class CatalogChildrenView extends Backbone.View

	initialize: (options) ->
		_.extend(@, options)
		@$el = $(@el)
		catalog_id = @.catalog_id
		@get_catalog_children(catalog_id)

	template: (model) ->
		_.template("<li><a href='/category/<%= model.get('id') %>'><%=model.get('name') %></a></li>")(model)
	
	get_catalog_children: (catalog_id) ->
		@collection = new Backbone.Collection()
		@collection.bind("reset", @add_all, @)
		@collection.fetch(url: "/catalog/#{ catalog_id}/children_categories")

	add_all: (models)->
		models.each (model) =>
			@$el.append(@template(model: model))


root.CatalogChildrenView = CatalogChildrenView
root.CatalogView = CatalogView