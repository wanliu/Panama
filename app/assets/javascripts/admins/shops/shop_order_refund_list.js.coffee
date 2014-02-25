#= require transactions/2columns_viewport
#= require transactions/card_item
#= require 'admins/shops/shop_order_refund_card'

root = (window || @)

class Refunds extends Backbone.Collection

class OrderRefund extends CardItemView
  events: {
    "click .actions .dispose" : "dispose"
  }
  initialize: (options) ->
    _.extend(@, options)
    super    

  get_register_view: () ->
    view = new ShopOrderRefundCard(
      el: @$(".full-mode .order_refund"),
      shop: @shop,
      dialogState: true
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

  dispose: () ->
    $.ajax(
      url: "#{@model.url()}/dispose",      
      type: "POST",
      dataType: "JSON",
      success: (data) ->
        window.location.href = "#open/#{data.id}/refund"
        window.location.reload()
    )



class root.ShopOrderRefundList extends CardItemListView

  initialize: (options) ->
    @shop = options.shop
    @columns_options = {
      secondContainer : ".refund-detail",
      leftSide: "#left_sidebar",
      spaceName: "refund"      
    }
    @root = "/#{@shop.token}/order_refunds"
    super options
    @bind_realtime()

  add_one: (elem, model) ->
    @monitor_state(model.id)
    new OrderRefund(
      model: model,
      shop: @shop,
      el: elem
    )

  reset: () ->
    _.each @$(".refunds>.card_item"), (el) => @add_elem el

  bind_realtime: () ->  
    @client.monitor "#{@root}/create", (data) =>
      @realtime_create(data)

    @client.monitor "#{@root}/destroy", (data) =>
      @destroy data.refund_id

  monitor_state: (id) ->
    @client.monitor "#{@root}/#{id}/change_state", (data) =>
      @change_state(data)

    @client.monitor "#{@root}/#{id}/change_info", (data) =>
      model = @collection.get data.refund_id
      model.set(data.info) unless _.isEmpty(model)

  destroy: (id) ->
    model = @collection.get(id)
    model.trigger("remove") unless _.isEmpty(model)

  realtime_create: (data) ->
    $.ajax(
      url: "#{@remote_url}/#{data.refund_id}/mini_item",
      success: (html) =>
        @$(".refunds").prepend(html)
        item = @$(".card_item:eq(0)")
        @add_elem(item)
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

