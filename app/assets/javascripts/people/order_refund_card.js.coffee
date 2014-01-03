#describe 买家退货
#= require lib/transaction_card_base

root = window || @

class OrderRefundCard extends TransactionCardBase

  initialize: () ->
    super

  events: {
    "click .refuse_protect" : "toggle_panel"
    "click input.delivered" : "clickAction",
    "keyup input:text.delivery_code" : "change_delivery_code",
    'click .edit_rdprice' : 'edit_delivery_price',
    'blur input:text[name=edit_rdprice]' : 'update_delivery_price'
  }

  states:
    initial: 'none'

    events:  [
      { name: 'refresh_shipped_agree',    from: 'apply_refund',      to: 'waiting_delivery'},
      { name: 'refresh_shipped_agree',    from: 'apply_expired',     to: 'waiting_delivery' },
      { name: 'refresh_shipped_agree',    from: 'apply_failure',     to: 'waiting_delivery' },
      { name: 'refresh_unshipped_agree',  from: 'apply_refund',      to: 'complete'},
      { name: 'refresh_unshipped_agree',  from: 'apply_expired',     to: 'complete' },
      { name: 'refresh_unshipped_agree',  from: 'apply_failure',     to: 'complete' },
      { name: 'refresh_sign',             from: 'waiting_sign',      to: 'complete'},
      { name: 'refresh_refuse',           from: 'apply_refund',      to: 'apply_failure'},
      { name: 'delivered',                from: 'waiting_delivery',  to: 'waiting_sign' }
    ]

  change_delivery_code: () ->
    ###
    code = @delivery_code_val()
    button = @$('.transaction-actions .btn_event')
    if _.isEmpty(code)
      button.addClass("disabled")
    else
      button.removeClass("disabled")
    ###

  toggle_panel: (option) ->
    @$(".connect").toggle("slow")

  afterDelivered: (event, from, to, msg) ->
    code = @delivery_code_val()
    transport_type = @$("select[name=transport_type]").val()
    if _.isEmpty(code) && _.isEmpty(transport_type)
      @slideAfterEvent(event)
    else
      data = {delivery_code: code, transport_type: transport_type}
      url = @transaction.urlRoot
      @transaction.fetch(
        url: "#{url}/update_delivery",
        type: 'POST',
        data: data,
        success: () => @slideAfterEvent(event)
      )

  update_delivery_price: () ->
    url = @transaction.urlRoot
    price = @$input.val()
    if /^\d+.?\d+$/.test(price)
      old_price = @$rdp_panel.attr("data-value")
      if parseFloat(price) ==  parseFloat(old_price)
        @$rdp_panel.show()
        @$edit_rdp_panel.hide()
      else
        @transaction.fetch(
          url: "#{url}/update_delivery_price",
          type: 'POST',
          data: {delivery_price: price},
          success: () =>
            @$rdp_panel.attr('data-value', price)
            _price = @$rdp_panel.text().trim()
            _price = _price.replace(_price.substring(1, _price.length), " #{price}")
            @$rdp_panel.html(_price)
            @$rdp_panel.show()
            @$edit_rdp_panel.hide()
        )
    else
      pnotify({
        type: "error",
        title: "编辑出错"
        text: "请输入正确的运费！"
      })
      @$input.focus()

  edit_delivery_price: () ->
    @$input = $("input:text[name='edit_rdprice']")
    price = @$input.val()
    @$rdp_panel = @$(".rdp_panel")
    @$rdp_panel.hide();
    @$edit_rdp_panel = @$(".edit_rdp_panel")
    @$edit_rdp_panel.show();
    @$input.focus();

  realtime_url: () ->
    "notify:/order_refunds#{super}"

  delivery_code_val: () ->
    @$("input:text.delivery_code").val()

root.OrderRefundCard = OrderRefundCard