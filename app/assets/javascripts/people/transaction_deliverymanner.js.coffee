#管理配送方式
class DeliveryManner extends Backbone.View
  events: {
    "click .title" : "chose_manner"
  }

  initialize: (options) ->
    _.extend(@, options)

    @$radio = @$("input:radio")
    @name = @$('.name').text().trim()
    @code = @$(".code").text().trim()

  chose_manner: () ->
    @$radio[0].checked = true
    @set_name(name: @name, code: @code)


class TransactionDeliveryManner extends Backbone.View
  events: {
    "click .delivery_manner .mdify_show" : "toggleMdify",
    'click .delivery_manner input:button.mdify' : "toggle_delivery_manner"
  }

  initialize: (options) ->
    @panel = @$(".delivery_manner .delivery_manner_panel")
    @chose_panel = @$(".delivery_manner .chose_delivery_manner_panel")
    @delivery_select_panel = @$(".delivery-select")

    @load_list()


  toggleMdify: () ->
    @panel.hide()
    @chose_panel.slideDown()

  toggle_delivery_manner: () ->
    @chose_panel.slideUp () =>
      @panel.show()

  load_list: () ->
    lis = @chose_panel.find("ul>li")
    _.each lis, (li) =>
      new DeliveryManner(
        set_name: _.bind(@set_name, @),
        el: $(li))

  set_name: (delivery) ->
    @panel.find(".chose_name").html(delivery.name)
    if delivery.code == "local_delivery"
      @delivery_select_panel.slideUp()
    else
      @delivery_select_panel.slideDown()
