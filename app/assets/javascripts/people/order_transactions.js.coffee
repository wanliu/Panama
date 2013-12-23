#= require lib/table_list
#= require people/transaction_card

root = (window || @)

class Transactions extends Backbone.Collection

class TransactionView extends Backbone.View
  events: {
    "click .btn_delete" : "destroy"
  }
  initialize: (options) ->
    _.extend(@, options)
    @model.bind("remove", @remove, @)
    @model.bind("change:state", @change_state, @)
    @model.bind("change:register", @register_view, @)
    @register_view()

  remove: () ->
    @card.remove() unless _.isEmpty(@card)
    super

  change_state: () ->
    unless _.isEmpty(@card)
      @card.stateChange(event: @model.get("event"))

    @change_table_state()

  register_view: () ->
    if @model.get("register")
      @card = new TransactionCard({
        el: @$(".detail .transaction")
      })
      @card.transaction.bind("change:state", @card_change_state, @)

  card_change_state: () ->
    unless _.isEmpty(@card)
      @set_state(@card.transaction.get("state"))
      @model.set(state_title: @card.transaction.get("state_title"))

    @change_table_state()

  set_state: (state) ->
    @model.attributes.state = state
    @model._currentAttributes.state = state

  change_table_state: () ->
    @$(".state_title").html(@model.get("state_title"))

  destroy: (event) ->
    if confirm("要取消这笔交易吗?")
      @model.destroy({
        success: (model, data) =>
          @remove()
      })

    false

class root.OrderTransactions extends Backbone.View

  initialize: (options) ->
    @$el = $(@el)
    @remote_url = options.remote_url

    @collection = new Transactions
    @collection.url = @remote_url
    @collection.bind("add", @add_one, @)
    @load_table_list()
    @reset()
    @realtime_load()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    new TransactionView(
      model: model,
      el: elem
    )

  reset: () ->
    _.each @$(".item"), (el) =>
      @collection.add(
        elem: $(el),
        register: false,
        id: $(el).attr('data-value-id'))

  register: (id) ->
    model = @collection.get(id)
    model.set(register: true) unless _.isEmpty(model)

  realtime_load: () ->
    @client = window.clients.socket

    @client.subscribe "notify:/order_transactions/change_state", (data) =>
      @change_state data

  change_state: (data) ->
    model = @collection.get(data.order_id)
    unless _.isEmpty(model)
      model.set({
        state: data.state,
        event: data.event,
        state_title: data.state_title})

  load_table_list: () ->
    @table = new TableListView(
      el: @$el,
      remote_url: @remote_url,
      bindView: (view) => @register(view.model.id)
    )