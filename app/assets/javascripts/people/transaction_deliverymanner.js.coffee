#管理运输方式

define ["jquery", "backbone"], ($, Backbone) ->

  class TransactionDeliveryManner extends Backbone.View
    events: {
      "click .mdify_show" : "toggleMdify",
      'click input:button.mdify' : "toggle_delivery_manner"
    }

    initialize: (options) ->
      @panel = @$(".delivery_manner_panel")
      @chose_panel = @$(".chose_delivery_manner_panel")

    toggleMdify: () ->
      @panel.hide()
      @chose_panel.slideDown()

    toggle_delivery_manner: () ->
      @chose_panel.slideUp () =>
        @panel.show()
