#= require lib/table_list
#= require admins/shops/shop_direct_transaction

root = (window || @)

class Transactions extends Backbone.Collection

class DirectTransaction extends CardItemView
  events: {
    "click .actions .dispose" : "dispose"
  }

  initialize: (options) ->
    _.extend(@, options)
    super
    @model.bind("undispose", _.bind(@undispose, @))

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

  undispose: () ->
    @$(".actions .dispose").remove()
    $.ajax(
      url: "#{@model.url()}/operator",
      type: 'GET',
      success: (data) =>
        $(".actions ul", @$header).prepend(data)
    )

  dispose: () ->
    $.ajax(
      url: "#{@model.url()}/dispose",
      type: "POST",
      dataType: "JSON",      
      success: (data) => 
        window.location.href = "#open/#{data.id}/direct"
        window.location.reload()
    )


class root.ShopDirectTransactionList extends CardItemListView
  
  initialize: (options) ->
    @shop = options.shop
    @columns_options = {
      leftSide: "#left_sidebar",
      secondContainer: ".direct-detail",
      spaceName: "direct"
    }
    super options
    @load_realtime()

  add_one: (elem, model) ->

    @monitor_state model.id
    new DirectTransaction(
      model: model,
      shop: @shop,
      el: elem
    )

    @$(".notify-message").remove()

  reset: () ->
    _.each @$(".directs>.card_item"), (el) => @add_elem el

  load_realtime: () ->
    @monitor_destroy()

    @client.monitor "/shops/#{@shop.token}/direct_transactions/dispose", (data) =>
      @monitor_dispose(data)

  monitor_dispose: (data) ->
    model = @collection.get(data.direct_id)
    model.trigger("undispose") unless _.isEmpty(model)

  monitor_destroy: () ->
    url = "/#{@shop.token}/direct_transactions/destroy"

    @client.monitor url, (data) => @destroy data.direct_id
    @client.monitor "/shops#{url}", (data) => @destroy data.direct_id

  monitor_state: (direct_id) ->
    url = "/#{@shop.token}/direct_transactions/#{direct_id}/change_state"

    @client.monitor url, (data) => @change_state(data)
    @client.monitor "/shops#{url}", (data) => @change_state(data)

  change_state: (data) ->
    model = @collection.get(data.direct_id)
    model.set(
      state: data.state,
      state_title: data.state_title
    )  unless _(model).isEmpty()

  destroy: (id) ->
    model = @collection.get(id)
    model.trigger("remove") unless _(model).isEmpty()
