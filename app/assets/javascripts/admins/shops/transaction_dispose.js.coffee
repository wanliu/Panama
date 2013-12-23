#处理订单
#= require jquery
#= require backbone
#= require admins/shops/transaction_realtime

exports = window || @

class Transaction extends Backbone.Model
  set_url: (shop_name) ->
    @urlRoot = "/shops/#{shop_name}/admins/#{@get('_type')}"

  dispose: (callback) ->
    $.ajax(
      url: "#{@urlRoot}/#{@id}/dispose"
      type: "POST",
      success: callback
    )

class TransactionList extends Backbone.Collection
  model: Transaction

class TransactionEvent extends Backbone.View
  tagName: "tr"
  events:
    "click .dispose" : "dispose"

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$el.html @template.render(@model.toJSON())
    @model.bind("change:unmessages_count", @change_message_count, @)
    @model.bind("change:state_title", @change_state, @)
    @model.bind("remove", @remove, @)

  dispose: () ->
    @model.dispose (data, xhr)  =>
      #@show_tran template

  show_tran: (template) ->
    if first_tran_el.length <= 0
      @tran_panel.append(template)
    else
      @tran_panel.prepend(template)

    @tran_card @tran_panel.find("##{@elem_id()}")
    @remove_tran()

  remove_tran: () ->
    @trigger("remove_tran", @model)

  render: () ->
    @$el

  change_message_count: () ->
    @$(".message_count").html(@model.get("unmessages_count"))

  change_state: () ->
    @$(".state").html(@model.get("state_title"))

  elem_id: () ->
    if @model.get("_type") == "direct_transactions"
      "direct#{@model.id}"
    else
      "order#{@model.id}"

class exports.TransactionDispose extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @transactions = new TransactionList()
    @transactions.bind("add", @add_data, @)
    @direct_transactions = new TransactionList()
    @direct_transactions.bind("add", @add_data, @)

    @init_el()
    @bind_realtime()
    @notice_msg()

  add_data: (model) ->
    model.set_url(@shop.name)
    view = new TransactionEvent(_.extend({}, @tranOpts[model.get('_type')],
      model: model,
      template: @template
    ))

    @realtime.change_state model.id, (data) =>
      @realtime_change data, model.get("_type")

    view.bind("remove_tran", _.bind(@remove_tran, @))
    @$tbody.append view.render()
    @notice_msg()

  add_order: (data) ->
    @transactions.add(_.extend({}, data, {_type: "transactions"}))

  add_direct: (data) ->
    @direct_transactions.add(_.extend({}, data, {_type: "direct_transactions"}))

  add_orders: (items) ->
    _.each items, (item) =>
      @add_order(item)

  add_directs: (items) ->
    _.each items, (item) =>
      @add_direct(item)

  init_el: () ->
    @$tbody = @$("tbody")

  remove_tran: (model) ->
    @transactions.remove model
    model.trigger("remove")
    @notice_msg()

  notice_msg: () ->
    if @transactions.length <= 0 && @direct_transactions.length <= 0
      @$tbody.html('')
      @$tbody.append("
      <tr class='notice_message'>
        <td colspan='8'>暂时没未处理单</td>
      </tr>")
    else
      @$tbody.find("tr.notice_message").remove()

  bind_realtime: () ->
    @realtime = new TransactionRealTime @shop_key()
    @realtime.create (data) =>
      @fetch_data(data.order_id, "transactions")

    @realtime.dispose (data) =>
      pnotify(text: data.content, avatar: data.avatar)
      @realtime_destroy data.order_id, "transactions"

    @realtime.destroy (data) =>
      @realtime_destroy data.order_id, "transactions"

    @realtime.chat (data) =>
      @realtime_chat data, "transactions"

  fetch_data: (id, type) ->
    model = new Transaction(_type: type, id: id)
    model.set_url(@shop.name)
    model.fetch success: (model, data) => @add(data, type)

  realtime_destroy: (id, type) ->
    model = @where_transaction(id, type)
    @remove_tran model if model?

  realtime_chat: (data, type) ->
    model = @where_transaction(data.order_id, type)
    if model?
      model.set("unmessages_count", data.unmessages_count)

  realtime_change: (data, type) ->
    model = @where_transaction(data.order_id, type)
    if model?
      model.set("state_title", data.state_title)

  where_transaction: (id, type) ->
    if type == "direct_transactions"
      @direct_transactions.get(id)
    else
      @transactions.get(id)

  shop_key: () ->
    @shop.token

  add: (data, type) ->
    if type == "direct_transactions"
      @add_direct data
    else
      @add_order data

