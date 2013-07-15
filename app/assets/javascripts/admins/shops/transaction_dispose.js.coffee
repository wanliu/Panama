#处理订单
#= require jquery
#= require backbone
#= require lib/realtime_client

exports = window || @

class Transaction extends Backbone.Model
  set_url: (shop_name) ->
    @urlRoot = "/shops/#{shop_name}/admins/transactions"
  dispose: (callback) ->
    $.ajax(
      url: "#{@urlRoot}/#{@.id}/dispose"
      type: "POST",
      success: callback
    )

class TransactionList extends Backbone.Collection
  model: Transaction

class TransactionEvent extends Backbone.View
  tagName: "tr"
  events: {
    "click .dispose" : "dispose"
  }

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @$el.html @template.render(@model.toJSON())
    @model.bind("change:unmessages_count", @change_message_count, @)
    @model.bind("change:state_title", @change_state, @)
    @model.bind("remove", @remove, @)

  dispose: () ->
    @model.dispose (template, xhr)  =>
      @show_tran template

  show_tran: (template) ->
    first_tran_el = @first_transaction()
    if first_tran_el.length <= 0
      @tran_panel.append(template)
    else
      first_tran_el.before(template)

    @tran_card @tran_panel.find("#order#{@model.id}")
    @remove_tran()

  remove_tran: () ->
    @trigger("remove_tran", @model)

  first_transaction: () ->
    @tran_panel.find(">.transaction:eq(0)")

  render: () ->
    @$el

  change_message_count: () ->
    @$(".message_count").html(@model.get("unmessages_count"))

  change_state: () ->
    @$(".state").html(@model.get("state_title"))

class exports.TransactionDispose extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @transactions = new TransactionList()
    @transactions.bind("add", @add_data, @)
    @init_el()
    @bind_realtime()
    @notice_msg()

  add_data: (model) ->
    model.set_url(@shop.name)
    view = new TransactionEvent(_.extend({}, @tranOpts,
      model: model,
      template: @template
    ))
    view.bind("remove_tran", _.bind(@remove_tran, @))
    @$tbody.append view.render()
    @notice_msg()

  add: (data) ->
    @transactions.add(data)

  init_el: () ->
    @$tbody = @$("tbody")

  remove_tran: (model) ->
    @transactions.remove model
    model.trigger("remove")
    @notice_msg()

  notice_msg: () ->
    if @transactions.length <= 0
      @$tbody.html('')
      @$tbody.append("
      <tr class='notice_message'>
        <td colspan='7' style='text-align:center;'>暂时没未处理单</td>
      </tr>")
    else
      @$tbody.find("tr.notice_message").remove()

  bind_realtime: () ->
    @client = Realtime.client(@realtime_url)

    @client.subscribe "/transaction/#{@shop_key()}/un_dispose", (info) =>
      data = info.values
      switch info.type
        when "chat"
          @realtime_chat(data)
        when "new"
          @add data
        when "change"
          @realtime_change(data)
        when "dispose"
          @realtime_dispose(data)

  realtime_dispose: (data) ->
    model = @transactions.get(data.id)
    if model?
      @remove_tran model

  realtime_chat: (data) ->
    model = @transactions.get(data.owner.id)
    if model?
      model.set("unmessages_count", data.owner.unmessages_count)
    else
      @add data.owner

  realtime_change: (data) ->
    model = @transactions.get(data.id)
    if model?
      model.set("state_title", data.state_title)

  shop_key: () ->
    @shop.id