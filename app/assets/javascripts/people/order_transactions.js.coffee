#= require transactions/2columns_viewport
#= require people/transaction_card

root = (window || @)

class TransactionView extends CardItemView
  events: {
    "click .btn_delete" : "destroy"
  }
  initialize: (options) ->
    _.extend(@, options)
    super    

  get_register_view: () ->
    view = new TransactionCard({
      el: @$(".full-mode .transaction")
    })
    view.transaction.bind("change:state", @card_change_state, @)
    view

  card_change_state: () ->
    unless _.isEmpty(@card)
      @set_state(@card.transaction.get("state"))
      @model.set(state_title: @card.transaction.get("state_title"))

    super

  destroy: (event) ->
    if confirm("要取消这笔交易吗?")
      @model.destroy(
        success: (model, data) => @remove()
      )

    false

class root.OrderTransactions extends CardItemListView

  initialize: (options) ->
    @columns_options = {
      secondContainer: ".order-detail",
      spaceName: "order"
    }

    super options

  add_one: (elem, model) ->

    @monitor_state model.id    
    new TransactionView(
      model: model,
      el: elem
    )

  reset: () ->
    _.each @$(".orders>.card_item"), (el) => 
      @add_elem(el)

  monitor_state: (order_id) ->
    @client.monitor "/transactions/#{order_id}/change_state", (data) =>
      @change_state data

    @client.monitor "/transactions/#{order_id}/change_delivery_price", (data) =>
      @change_total(data)

  change_total: (data) ->
    model = @collection.get(data.order_id)
    model.set({total: data.stotal}) unless _.isEmpty(model)

  change_state: (data) ->
    model = @collection.get(data.order_id)
    unless _.isEmpty(model)
      model.set({
        state: data.state,
        event: data.event,
        state_title: data.state_title})