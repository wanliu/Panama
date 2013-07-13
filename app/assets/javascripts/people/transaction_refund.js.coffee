#交易退货
#= require lib/notify

class TransactionRefund extends Backbone.Model
  set_url: (url) ->
    @urlRoot = url

  create: (callback) ->
    @fetch({
      url: "#{@urlRoot}/refund",
      type: "POST",
      data: {order_refund: @toJSON()},
      success: callback.success
      error: callback.error
    })

class TransactionRefundView extends Backbone.View
  events: {
    "click .returned-event"        : "toggle_panel",
    "submit .returned_panel form"  : "create"
  }

  initialize: (options) ->
    @remote_url = @options.remote_url
    @$details = @$(".products>table>tbody>tr")
    @$panel = @$(".returned_panel")
    @$form = @$panel.find("form")

  toggle_panel: () ->
    @$panel.slideToggle(_.bind(@toggle_chose_product, @))

  toggle_chose_product: () ->
    state = if @$panel.css("display") == "none" then false else true
    @each_details (row) ->
      check = @row_checkbox(row)
      if check.length > 0
        if state then check.show() else check.hide()
        check[0].checked = state

  create: () ->
    data = @get_form_data()
    data["product_items"] = @get_details()
    if data.product_items.length <= 0
      @notify("请选择退货商品!", "error")
      return false

    if data.hasOwnProperty('delivery_price')
      if _.isEmpty(data.delivery_price)
        @$("input.delivery_price").val(0)

      unless /^\d*\.?\d+$/.test data.delivery_price
        @notify("请输入正确运费!", "error")
        return false

    @refund = new TransactionRefund(data)
    @refund.set_url(@remote_url)
    @refund.create
      success: (model, data) =>
        @notify("退货申请成功, 等待商家确认!", "success")
        @toggle_panel()
      error: (model, data) =>
        error_message = JSON.parse(data.responseText)
        error_message = error_message.message if error_message.message
        @notify("错误! #{ error_message }", 'error')
    false

  get_form_data: () ->
    data = @$form.serializeArray()
    options = {}
    _.each data, (d) ->
      options[d.name] = d.value
    options

  get_details: () ->
    product_items = []
    @each_details (row) ->
      check = @row_checkbox(row)
      if check.length > 0 && check[0].checked
        product_items.push(row.attr('data-value-id'))

    product_items

  each_details: (callback) ->
    _.each @$details, (row) =>
      callback.call(@, $(row))

  row_checkbox: (row) ->
    row.find("input:checkbox")

  notify: (text, type) ->
    $.pnotify({
      title: "申请退货提示",
      text: text,
      type: type
    });

window.TransactionRefundView = TransactionRefundView
