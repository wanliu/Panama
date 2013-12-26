#= require 'lib/table_list'
#= require 'people/direct_transaction'

root = (window || @)

class Transactions extends Backbone.Collection

class DirectTransaction extends CardItemView
  events: {
    "click .summarize .btn_delete" : "destroy"
  }
  initialize: (options) ->
    _.extend(@, options)
    super

  get_register_view: () ->
    view = new DirectTransactionView(
      el: @$(".full-mode .direct"),
      login: @login
    )
    view.model.bind("change:state", @card_change_state, @)
    view

  card_change_state: () ->
    unless _.isEmpty(@card)
      @set_state(@card.model.get("state"))
      @model.set(state_title: @card.model.get("state_title"))

    super

  destroy: () ->
    if confirm "是否确定删除该订单？"
      @model.destroy success: () => @remove()

    false

class root.DirectTransactionList extends Backbone.View

  initialize: (options) ->
    @$el = $(@el)
    @remote_url = options.remote_url
    @login = options.login
    @collection = new Transactions
    @collection.url = @remote_url
    @collection.bind("add", @add_one, @)
    @load_table_list()
    @load_realtime()
    @reset()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    new DirectTransaction(
      model: model,
      login: @login,
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
    @table = new TransactionTwoColumnsViewport({
      el: @$el,
      secondContainer: ".direct-detail",
      remote_url: @remote_url,
      registerView: (view) => @register(view.model.id)
    });

  load_realtime: () ->
    @client = window.clients.socket