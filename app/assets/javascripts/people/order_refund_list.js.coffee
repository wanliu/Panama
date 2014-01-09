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

class root.OrderRefundList extends Backbone.View

  initialize: (options) ->
    @$el = $(@el)
    @remote_url = options.remote_url
    @collection = new Refunds
    @collection.url = @remote_url
    @collection.bind("add", @add_one, @)
    @load_realtime()
    @reset()
    @load_table_list()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    @monitor_state(model.id)
    new OrderRefund(
      model: model,
      el: elem
    )

  reset: () ->
    _.each @$(".refunds>.card_item"), (el) => @add el

  add: (item) ->
    @collection.add(
      elem: $(item),
      register: false,
      id: $(item).attr('data-value-id'))

  register: (id) ->
    model = @collection.get(id)
    model.set(register: true) unless _.isEmpty(model)

  load_table_list: () ->
    @table = new TransactionTwoColumnsViewport({
      el: @$el,
      secondContainer: ".refund-detail",
      remote_url: @remote_url,
      registerView: (view) => 
        state = view.model.get("fetch_state")
        if !_.isEmpty(state) && state
          delete view.model.attributes.fetch_state
          @add(view.$el)
          
        @register(view.model.id)
    });

  load_realtime: () ->
    @client = window.clients

  monitor_state: (id) ->
    @client.monitor "/order_refunds/#{id}/change_state", (data) =>
      @change_state(data)

  change_state: (data) ->
    model = @collection.get data.refund_id
    unless _.isEmpty(model)
      model.set(
        state: data.state,
        event: data.event,
        state_title: data.state_title
      )
