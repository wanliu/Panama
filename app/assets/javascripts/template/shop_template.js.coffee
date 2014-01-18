#= require 'lib/card_info'

root = (window || @)

class root.ShopViewTemplate extends Backbone.View
  className: "shop info-wrapper"

  initialize: () ->
    @$el = $(@el)
    @$el.attr("shop-id", @model.id)
    @template = $(Handlebars.compile($("#shop_template").html())(@model))
    @$el.html(@template)

  render: () ->    
    @
