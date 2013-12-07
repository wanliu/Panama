# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
root  =  window || @

class CatalogView extends Backbone.View
  tagName: "li"
  events:
    "click" : "search"

  initialize: (options) ->
    _.extend(@, options)
    $(@el).html(@template())

  template: () ->
    _.template("<a href='javascript:void(0)'><%=title %></a>")(@model.toJSON())

  render: () ->
    $(@el)

  search: () ->
    $(@el).parent().find("li").removeClass("active")
    $(@el).addClass("active")
    @trigger("search", {catalog_id: @model.id})

class CatalogViewList extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @get_catalog()

  get_catalog: () ->
    @collection = new Backbone.Collection()
    @collection.bind("reset", @add_all, @)
    @collection.fetch(url: "/catalog")

  add_all: (models)->
    models.each (model) =>
      view = new CatalogView(model: model)
      view.bind("search", _.bind(@search), @)
      @$el.append(view.render())

  search: (data) ->



class CatalogChildrenView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    catalog_id = @catalog_id
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
root.CatalogViewList = CatalogViewList