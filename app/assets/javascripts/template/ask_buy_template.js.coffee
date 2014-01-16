root = (window || @)

class root.AskBuyViewTemplate extends Backbone.View
  initialize: () ->
    @template = Hogan.compile($("#ask_buy-preview-template").html())
    @$el = $(@template.render(@model)) if @template

  render: () ->
    $(".notify", @$el).html("已经有商家参与") if @model.status == 1
    @$el.find(".price").html(@model.price.toString().toMoney()) if @model.price
    @