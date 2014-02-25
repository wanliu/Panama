#= require lib/table_list
#= require people/transaction_refund

root = (window || @)

class Refunds extends Backbone.Collection

class OrderRefund extends CardItemView
  events: {
    "click .summarize .btn_delete" : "destroy"
  }
  initialize: (options) ->
    _.extend(@, options)
    super    

  get_register_view: () ->
    view = new OrderRefundCard(
      el: @$(".full-mode .order_refund"),
      dialogState: false
    )
    view.transaction.bind("change:state", @card_change_state, @)
    data = view.transaction.toJSON()
    @syn_state(data.state, data.state_title)
    view

  card_change_state: () ->
    unless _.isEmpty @card
      data = @card.transaction.toJSON()
      @syn_state(data.state, data.state_title)

    super

  destroy: () ->
    if confirm "是否确定删除退货单?"
      @model.destroy success: () => @remove()

    false

class root.OrderRefundList extends CardItemListView

  initialize: (options) ->
    @columns_options = {
      secondContainer: ".refund-detail",
      spaceName: "refund"
    }

    super options

  add_one: (elem, model) ->
    @monitor_info model.id
    @monitor_state model.id
    new OrderRefund(
      model: model,
      el: elem
    )

  reset: () ->
    _.each @$(".refunds>.card_item"), (el) => @add_elem el

  monitor_state: (id) ->
    @client.monitor "/order_refunds/#{id}/change_state", (data) =>
      @change_state(data)

  monitor_info: (id) ->
    @client.monitor "/order_refunds/#{id}/change_info", (data) =>
      @change_info(data)

  change_state: (data) ->
    model = @collection.get data.refund_id
    unless _.isEmpty(model)
      model.set(
        state: data.state,
        event: data.event,
        state_title: data.state_title
      )

  change_info: (data) ->
    model = @collection.get data.refund_id
    model.set(data.info) unless _.isEmpty(model)

