#= require lib/table_list
#= require admins/shops/shop_transaction_card

root = (window || @)

class Transactions extends Backbone.Collection

class TransactionView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @model.bind("destroy", @remove, @)
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
      @card = new ShopTransactionCard({
        el: @$(".detail .transaction"),
        shop: @shop
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

class root.ShopOrderTransactions extends Backbone.View

  initialize: (options) ->
    @shop = options.shop
    @$el = $(@el)
    @remote_url = options.remote_url

    @collection = new Transactions
    @collection.bind("add", @add_one, @)
    @load_table_list()
    @reset()
    @realtime_load()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    new TransactionView(
      model: model,
      el: elem,
      shop: @shop
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

    @client.subscribe "notify:/shops/#{@shop.token}/order_transactions/destroy", (data) =>
      @destroy data

    @client.subscribe "notify:/shops/#{@shop.token}/order_transactions/change_state", (data) =>
      @change_state data

  destroy: (data) ->
    model = @collection.get(data.order_id)
    model.destroy() unless _.isEmpty(model)

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
      bindView: (view) =>  @register(view.model.id)
    )