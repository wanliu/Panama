#= require lib/table_list
#= require admins/shops/shop_direct_transaction

root = (window || @)

class Transactions extends Backbone.Collection

class DirectTransaction extends CardItemView

  initialize: (options) ->
    _.extend(@, options)
    super

  get_register_view: () ->
    view = new ShopDirectTransactionView(
      el: @$(".full-mode .direct")
      shop: @shop
    )
    view.model.bind("change:state", @card_change_state, @)
    view

  card_change_state: () ->
    unless _.isEmpty(@card)
      @set_state(@card.model.get("state"))
      @model.set(state_title: @card.model.get("state_title"))

    super

class root.ShopDirectTransactionList extends CardItemListView

  initialize: (options) ->
    @shop = options.shop
    @columns_options = {
      leftSide: "#left_sidebar",
      secondContainer: ".direct-detail"
    }
    super options
    @load_realtime()

  add_one: (elem, model) ->

    @monitor_state model.id
    new DirectTransaction(
      model: model,
      shop: @shop,
      el: elem
    )

  reset: () ->
    _.each @$(".directs>.card_item"), (el) => @add_elem el

  load_realtime: () ->
    @client.monitor "/#{@shop.token}/direct_transactions/destroy", (data) =>
      @destroy data.direct_id

  monitor_state: (direct_id) ->
    @client.monitor "/#{@shop.token}/direct_transactions/#{direct_id}/change_state", (data) =>
      @change_state(data)

  change_state: (data) ->
    model = @collection.get(data.direct_id)
    model.set(
      state: data.state,
      state_title: data.state_title
    )  unless _(model).isEmpty()

  destroy: (id) ->
    model = @collection.get(id)
    model.trigger("remove") unless _(model).isEmpty()
