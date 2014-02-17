#处理订单
#= require jquery
#= require backbone
#= require admins/shops/transaction_realtime

exports = window || @

class Transaction extends Backbone.Model

  dispose: (callback) ->
    $.ajax(
      url: "#{@url()}/dispose"
      type: "POST",
      dataType: "JSON",
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
    @model.bind("change:state_title", @change_state, @)
    @model.bind("change:stotal", @change_stotal, @)
    @model.bind("change:address", @change_address, @)

    @model.bind("remove", @remove, @)

  dispose: (event) ->
    @model.dispose (data, xhr) =>
      return if _.isEmpty(data)
      @$el.remove()
      window.location.href = "#open/#{data.id}/#{@workName}"
      # window.location.reload();

  change_address: () ->
    @$(".address").html(@model.get("address"))

  change_stotal: () ->
    @$(".stotal").html(@model.get("stotal"))

  render: () ->
    @$el

  change_state: () ->
    @$(".state").html(@model.get("state_title"))


class exports.TransactionDispose extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @transactions = new TransactionList()
    @transactions.url = "/shops/#{@shop.name}/admins/#{@_type}"
    @transactions.bind("add", @add_data, @)

    @init_el()
    @bind_realtime()
    @notice_msg()

  add_data: (model) ->
    view = new TransactionEvent(
      model: model,
      workName: @workName(),
      template: @template)

    @realtime.change_state model.id, (data) =>
      @realtime_change data

    @realtime.change_info model.id, (data) =>
      @realtime_change_info data

    view.bind("remove_tran", _.bind(@remove_tran, @))
    @$tbody.prepend view.render()
    @notice_msg()

  add_one: (data) ->
    @transactions.add(data)

  init_el: () ->
    @$tbody = @$("tbody")
    @$thead = @$("thead")

  remove_tran: (model) ->
    @transactions.remove model
    model.trigger("remove")
    @notice_msg()

  notice_msg: () ->
    if @transactions.length <= 0
      @$tbody.html('')
      @$tbody.append("
      <tr class='notice_message'>
        <td colspan='#{$("th", @$thead).length}'>暂时没未处理单</td>
      </tr>")
    else
      @$tbody.find("tr.notice_message").remove()

  bind_realtime: () ->
    @realtime = new TransactionRealTime @shop_key(), @_type
    @realtime.create (data) =>
      @fetch_data data[@type_key()]

    @realtime.dispose (data) =>
      pnotify(text: data.content, avatar: data.avatar)
      @realtime_destroy data[@type_key()]

    @realtime.destroy (data) =>
      @realtime_destroy data[@type_key()]

  fetch_data: (id) ->
    model = new Transaction(id: id)
    url = "#{@transactions.url}/#{id}"
    model.fetch url: url, success: (model, data) => @add_one(data)

  realtime_destroy: (id) ->
    model = @transactions.get(id)
    @remove_tran model if model?

  realtime_change: (data) ->
    model = @transactions.get(data[@type_key()])
    model.set("state_title", data.state_title) if model?

  realtime_change_info: (data) ->
    model = @transactions.get(data[@type_key()])
    model.set(data.info) if model?

  shop_key: () ->
    @shop.token

  add: (items) ->
    length = items.length-1
    if length >= 0
      for i in [length..0]
        @add_one items[i]

    return

  type_key: () ->
    switch @_type
      when "direct_transactions" then "direct_id"
      when "transactions" then "order_id"
      else "id"

  workName: () ->
    switch @_type
      when "direct_transactions" then "direct"
      when "transactions" then "order"
      else ""

