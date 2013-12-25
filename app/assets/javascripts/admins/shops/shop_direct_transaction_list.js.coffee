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

class root.ShopDirectTransactionList extends Backbone.View

  initialize: (options) ->
    @$el = $(@el)
    @remote_url = options.remote_url
    @shop = options.shop
    @collection = new Transactions
    @collection.url = @remote_url
    @collection.bind("add", @add_one, @)
    @load_table_list()
    @load_realtime()
    @reset()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    @monitor_state model.id
    new DirectTransaction(
      model: model,
      shop: @shop,
      el: elem
    )

  reset: () ->
    _.each @$(".directs>.card_item"), (el) => @add el

  add: (item) ->
    @collection.add(
      elem: $(item),
      register: false,
      id: $(item).attr('data-value-id'))

  register: (id) ->
    model = @collection.get(id)
    model.set(register: true) unless _.isEmpty(model)

  load_table_list: () ->
    @table = new TransactionTwoColumnsViewport(
      el: @$el,
      secondContainer: ".direct-detail",
      warpClass: ".directs",
      remote_url: @remote_url,
      leftSide: "#left_sidebar",
      registerView: (view) => @register(view.model.id)
    )

  load_realtime: () ->
    @client = window.clients.socket

    @client.subscribe "notify:/#{@shop.token}/direct_transactions/destroy", (data) =>
      @destroy data.direct_id

  monitor_state: (direct_id) ->
    @client.subscribe "notify:/#{@shop.token}/direct_transactions/#{direct_id}/change_state", (data) =>
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
