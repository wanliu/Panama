
class window.ProductPreview extends Backbone.View
  events:
    'click .product .ask_buy_feature' : 'ask_buy'
    'click .product .in-box' : 'ask_buy'

  ask_buy: (event) ->
    try
      @load_view(event.currentTarget)
      link = $(".create_ask_buy")
      dialog = $("#{link.attr('data-target')}")
      dialog.on "shown", () =>
        ask_buy_view.fetch_product(@id)

      $(".modal-body", dialog).load link.attr("href"), () =>
        dialog.modal('show')

      false
    catch error
      false

  load_view: (target) ->
    @$el = @el = $(target).parents(".product")
    @id = @el.attr("product-id")
    @delegateEvents()
