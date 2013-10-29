
root = window || @

class Circle extends Backbone.Model

class CircleList extends Backbone.Collection
  model: Circle
  set_url: (url) ->
    @url = url

class CircleView extends Backbone.View
  className: "circle"

  initialize: () ->
    @$el = $(@el)

  render: () ->
    data = @model.toJSON()
    template = Hogan.compile($("#you-template-circle").html())
    @$el.html(template.render(data))

class MyCircleView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @circles = new CircleList()
    @circles.set_url(@url)
    @circles.bind("add", _.bind(@add, @))
    @circles.bind("reset", _.bind(@reset, @))
    @circles.fetch()

  add: (model) ->
    view = new CircleView(model: model)
    @el.append(view.render())

  reset: (collections) ->
    collections.each (model) =>
      @add(model)


class root.CommunityView extends Backbone.View

  initialize: () ->

  render: () ->

  fetch_circles: (url) ->
    new MyCircleView({
      url: url,
      el: @$(".circles")})