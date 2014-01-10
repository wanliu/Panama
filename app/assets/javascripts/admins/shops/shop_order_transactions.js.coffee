#= require transactions/2columns_viewport
#= require admins/shops/shop_transaction_card
#= require transactions/card_item

root = (window || @)

class Transactions extends Backbone.Collection

class TransactionView extends CardItemView

  initialize: (options) ->
    _.extend(@, options)
    super

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

class root.ShopOrderTransactions extends CardItemListView

  initialize: (options) ->
    @shop = options.shop

    @columns_options = {
      secondContainer: ".order-detail",
      leftSide: "#left_sidebar"
    }
    super options
    @realtime_load()

  add_one: (elem, model) ->
    @monitor_state model.id
    new TransactionView(
      model: model,
      el: elem,
      shop: @shop
    )

  reset: () ->
    _.each @$(".orders>.card_item"), (el) => @add_elem(el)

  realtime_load: () ->  
    @client.monitor "/#{@shop.token}/transactions/destroy", (data) =>
      @destroy data

  monitor_state: (order_id) ->
    @client.monitor "/#{@shop.token}/transactions/#{order_id}/change_state", (data) =>
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