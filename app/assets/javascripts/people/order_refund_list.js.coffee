#= require lib/table_list
#= require people/transaction_refund

root = (window || @)

class Refunds extends Backbone.Collection

class OrderRefund extends Backbone.View
  events: {
    "click .summarize .btn_delete" : "destroy"
  }
  initialize: (options) ->
    _.extend(@, options)
    @model.bind("change:register", @register_view, @)
    @model.bind("change:state", @change_state, @)

  register_view: () ->
    @view = new OrderRefundCard(
      el: @$(".detail .order_refund")
    )
    @transaction = @view.transaction
    @transaction.bind("change:state", @view_change_state, @)
    @set_state(@transaction.get("state"))
    @model.set(state_title: @transaction.get("state_title"))

  remove: () ->
    @view.remove() unless _.isEmpty(@view)
    super

  change_state: () ->
    @view.stateChange(event: @model.get("event")) unless _.isEmpty(@view)
    @change_table_state()

  change_table_state: () ->
    @$(".state_title").html(@model.get("state_title"))

  set_state: (state) ->
    @model.attributes.state = state
    @model._currentAttributes.state = state

  view_change_state: () ->
    @set_state()

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
    @load_table_list()
    @load_realtime()
    @reset()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    new OrderRefund(
      model: model,
      el: elem
    )

  reset: () ->
    _.each @$(".item"), (el) => @add el

  add: (item) ->
    @collection.add(
      elem: $(item),
      register: false,
      id: $(item).attr('data-value-id'))

  register: (id) ->
    model = @collection.get(id)
    model.set(register: true) unless _.isEmpty(model)

  load_table_list: () ->
    @table = new TableListView(
      el: @$el,
      remote_url: @remote_url,
      bindView: (view) => @register(view.model.id)
    )

  load_realtime: () ->
    @client = window.clients.socket

    @client.subscribe "notify:/order_refunds/change_state", (data) =>
      @change_state(data)

  change_state: (data) ->
    model = @collection.get data.refund_id
    unless _.isEmpty(model)
      model.set(
        state: data.state,
        event: data.event,
        state_title: data.state_title
      )
