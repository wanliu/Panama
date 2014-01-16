
root = (window || @)

class root.CircleViewTemplate extends Backbone.View
  initialize: () ->
    @template = Handlebars.compile($("#product-preview-template").html())
    @$el.html(@template(@model)) if @template

  render: () ->
    @
