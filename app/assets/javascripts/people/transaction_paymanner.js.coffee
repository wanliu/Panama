#管理付款方式

define ["jquery", "backbone"], ($, Backbone) ->

  class TransactionPayManner extends Backbone.View
    events: {
      "click .mdify_show" : "toggleMdify",
      'click input:button.mdify' : "toggle_paymanner"
    }

    initialize: (options) ->
      @panel = @$(".paymanner_panel")
      @chose_panel = @$(".chose_paymanner_panel")

    toggleMdify: () ->
      @panel.hide()
      @chose_panel.slideDown()

    toggle_paymanner: () ->
      @chose_panel.slideUp () =>
        @panel.show()

