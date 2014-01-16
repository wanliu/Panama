#= require 'lib/card_info'

root = (window || @)

class root.ShopViewTemplate extends Backbone.View
  className: "shop info-wrapper"

  initialize: () ->
    @$el = $(@el)
    @model.shop = @model
    @$el.attr("shop-id", @model.id)
    @template = $(Handlebars.compile($("#shop_template").html())(@model))
    @$el.html(@template)
    new ShopCardInfo(
      el: @template,
      model: @model
    )

  render: () ->    
    @
