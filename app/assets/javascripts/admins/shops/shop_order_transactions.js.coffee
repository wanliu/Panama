#= require transactions/2columns_viewport
#= require admins/shops/shop_transaction_card
#= require transactions/card_item

root = (window || @)

class Transactions extends Backbone.Collection

class TransactionView extends CardItemView
  events: {
    "click .actions .dispose" : "dispose"
  }
  initialize: (options) ->
    _.extend(@, options)
    super
    @model.bind("undispose", _.bind(@undispose, @))

  get_register_view: () ->
    view = new ShopTransactionCard({
      el: @$(".full-mode .transaction"),
      shop: @shop
    })
    view.transaction.bind("change:state", @card_change_state, @)
    view

  card_change_state: () ->
    unless _.isEmpty(@card)
      @set_state(@card.transaction.get("state"))
      @model.set(state_title: @card.transaction.get("state_title"))

    super

  dispose: () ->
    $.ajax(
      url: "#{@model.url()}/dispose",
      type: "POST",
      dataType: "JSON",
      success: (data) ->
        window.location.href = "#open/#{data.id}/order"
        window.location.reload()
    )

  undispose: () ->
    @$(".invalid-full").remove()
    @$(".actions .dispose").parent().remove()
    $.ajax(
      url: "#{@model.url()}/operator",
      type: 'GET',
      success: (data) =>
        $(".actions ul", @$header).prepend(data)
    )

class root.ShopOrderTransactions extends CardItemListView

  initialize: (options) ->
    @shop = options.shop

    @columns_options = {
      secondContainer: ".order-detail",
      leftSide: "#left_sidebar",
      spaceName: "order"
    }
    super options
    @realtime_load()

  add_one: (elem, model) ->
    @monitor_state model.id
    @monitor_change_info model.id
    new TransactionView(
      model: model,
      el: elem,
      shop: @shop
    )

  reset: () ->
    _.each @$(".orders>.card_item"), (el) => @add_elem(el)

  realtime_load: () ->  
    @monitor_destroy()
    @client.monitor "/shops/#{@shop.token}/transactions/dispose", (data) =>
      @dispose data

    #当前订单打开的话接单处理
    $(window).bind "orderUndispose", (e, data) => @dispose data

  monitor_change_info: (order_id) ->
    url = "/#{@shop.token}/transactions/#{order_id}/change_info"

    @client.monitor url, (data) => @change_info(data)
    @client.monitor "/shops#{url}", (data) => @change_info(data)

  monitor_destroy: () ->
    url = "/#{@shop.token}/transactions/destroy"
    @client.monitor url, (data) =>
      @destroy data

    @client.monitor "/shops#{url}", (data) =>
      @destroy data


  monitor_state: (order_id) ->
    url = "/#{@shop.token}/transactions/#{order_id}/change_state"

    @client.monitor url, (data) =>
      @change_state data

    @client.monitor "/shops#{url}", (data) =>
      @change_state data

  destroy: (data) ->
    model = @collection.get(data.order_id)
    model.trigger("remove") unless _.isEmpty(model)

  change_state: (data) ->
    model = @collection.get(data.order_id)
    unless _.isEmpty(model)
      model.set({
        state: data.state,
        event: data.event,
        state_title: data.state_title})

  dispose: (data) ->
    model = @collection.get(data.order_id)
    model.trigger("undispose") unless _.isEmpty(model)

  change_info: (data) ->
    model = @collection.get(data.order_id)
    model.set(data.info) unless _.isEmpty(model)
