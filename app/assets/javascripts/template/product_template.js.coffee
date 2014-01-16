
root = (window || @)

class root.ProductViewTemplate extends Backbone.View
  initialize: () ->
    @template = Hogan.compile($("#product-preview-template").html())
    @$el = $(@template.render(@model)) if @template

  render: () ->
    @$el.find(".price").html(@model.price.toString().toMoney()) if @model.price
    @
