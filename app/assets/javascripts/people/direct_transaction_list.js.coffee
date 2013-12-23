#= require 'lib/table_list'
#= require 'people/direct_transaction'

root = (window || @)

class Transactions extends Backbone.Collection

class DirectTransaction extends Backbone.View
  events: {
    "click .summarize .btn_delete" : "destroy"
  }
  initialize: (options) ->
    _.extend(@, options)
    @model.bind("change:register", @register_view, @)
    @model.bind("remove", @remove, @)

  register_view: () ->
    @view = new DirectTransactionView(
      el: @$(".detail .direct"),
      login: @login
    )

  remove: () ->
    @view.remove() unless _.isEmpty(@view)
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