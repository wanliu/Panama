#= require transactions/2columns_viewport
#= require transactions/card_item
#= require 'admins/shops/shop_order_refund_card'

root = (window || @)

class Refunds extends Backbone.Collection

class OrderRefund extends CardItemView

  initialize: (options) ->
    _.extend(@, options)
    super

  get_register_view: () ->
    view = new ShopOrderRefundCard(
      el: @$(".full-mode .order_refund"),
      shop: @shop
    )
    transaction = view.transaction
    transaction.bind("change:state", @card_change_state, @)
    data = transaction.toJSON()
    @syn_state(data.state, data.state_title)
    view

  card_change_state: () ->
    unless _.isEmpty(@card)
      @syn_state(
        @card.transaction.get('state'),
        @card.transaction.get('state_title'))

    super


class root.ShopOrderRefundList extends Backbone.View

  initialize: (options) ->
    @$el = $(@el)
    @remote_url = options.remote_url
    @shop = options.shop
    @collection = new Refunds
    @collection.url = @remote_url
    @collection.bind("add", @add_one, @)
    @load_table_list()
    @load_realtime()
    @reset()

  add_one: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    @monitor_state(model.id)
    new OrderRefund(
      model: model,
      shop: @shop,
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
      warpClass: ".refunds",
      remote_url: @remote_url,
      leftSide: "#left_sidebar",
      registerView: (view) => @register view.model.id
    })

  load_realtime: () ->
    @client = window.clients.socket
    @root = "notify:/#{@shop.token}/order_refunds"

    @client.subscribe "#{@root}/create", (data) =>
      @realtime_create(data)

    @client.subscribe "#{@root}/destroy", (data) =>
      @destroy data.refund_id

  monitor_state: (id) ->
    @client.subscribe "#{@root}/#{id}/change_state", (data) =>
      @change_state(data)

  destroy: (id) ->
    model = @collection.get(id)
    model.trigger("remove") unless _.isEmpty(model)

  realtime_create: (data) ->
    $.ajax(
      url: "#{@remote_url}/#{data.refund_id}/item",
      success: (html) =>
        @$(".refunds").prepend(html)
        item = @$(".card_item:eq(0)")
        @add(item)
        @table.add(item)
    )

  change_state: (data) ->
    model = @collection.get data.refund_id
    unless _.isEmpty(model)
      model.set(
        state: data.state,
        event: data.event,
        state_title: data.state_title
      )

