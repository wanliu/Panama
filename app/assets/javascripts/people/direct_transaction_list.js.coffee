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
    @model.bind("dispose", _.bind(@dispose, @))

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

  dispose: () ->
    $.ajax(
      url: "#{@model.url()}/operator",
      success: (data) =>
        $(".actions ul", @$header).prepend(data)
    )

class root.DirectTransactionList extends CardItemListView

  initialize: (options) ->
    @login = options.login
    @columns_options = {
      secondContainer: ".direct-detail",
      spaceName: "direct"
    }

    super options
    @monitor_dispose()


  add_one: (elem, model) ->

    new DirectTransaction(
      model: model,
      login: @login,
      el: elem
    )

  monitor_dispose: () ->
    @client.monitor "/direct_transactions/dispose", (data) =>
      model = @collection.get(data.direct_id)
      model.trigger("dispose") unless _.isEmpty(model)

  reset: () ->
    _.each @$(".directs>.card_item"), (el) => @add_elem el

