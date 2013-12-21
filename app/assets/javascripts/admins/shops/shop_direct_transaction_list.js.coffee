#= require lib/table_list
#= require admins/shops/shop_direct_transaction

root = (window || @)

class Transactions extends Backbone.Collection

class DirectTransaction extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @model.bind("change:register", @register_view, @)
    @model.bind("remove", @remove, @)

  register_view: () ->
    @view = new ShopDirectTransactionView(
      el: @$(".detail .direct")
    )

  remove: () ->
    @view.remove() unless _.isEmpty(@view)
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
    new DirectTransaction(
      model: model,
      shop: @shop,
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

    @client.subscribe "notify:/shops/#{@shop.token}/direct_transactions/create", (data) =>
      @realtime_create(data)

    @client.subscribe "notify:/shops/#{@shop.token}/direct_transactions/destroy", (data) =>
      @destroy data.direct_id

  realtime_create: (data) ->
    $.ajax(
      url: "#{@remote_url}/#{data.direct_id}/item",
      success: (html) =>
        $(".header", @$el).after(html)
        item = @$(".item:eq(0)")
        @add(item)
        @table.add(item)
    )

  destroy: (id) ->
    model = @collection.get(id)
    model.trigger("remove") unless _(model).isEmpty()
