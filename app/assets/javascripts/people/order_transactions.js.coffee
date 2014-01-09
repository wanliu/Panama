#= require transactions/2columns_viewport
#= require people/transaction_card

root = (window || @)

class Transactions extends Backbone.Collection

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

class root.OrderTransactions extends Backbone.View

  initialize: (options) ->
    @$el = $(@el)
    @remote_url = options.remote_url

    @collection = new Transactions
    @collection.url = @remote_url
    @collection.bind("add", @add_one, @)
    @realtime_load()    
    @reset()
    @load_table_list()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    @monitor_state model.id
    new TransactionView(
      model: model,
      el: elem
    )

  reset: () ->
    _.each @$(".orders>.card_item"), (el) => 
      @add_elem(el)

  add_elem: (el) ->
    @collection.add(
      elem: $(el),
      register: false,
      id: $(el).attr('data-value-id'))

  register: (id) ->
    model = @collection.get(id)
    model.set(register: true) unless _.isEmpty(model)

  realtime_load: () ->
    @client = window.clients

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

  load_table_list: () ->
    @table = new TransactionTwoColumnsViewport({
      el: @$el,
      secondContainer: ".order-detail",
      remote_url: @remote_url,
      registerView: (view) =>  
        state = view.model.get("fetch_state")
        if !_.isEmpty(state) && state
          delete view.model.attributes.fetch_state
          @add_elem(view.$el)

        @register(view.model.id)
    })