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

  getNotifyName: () ->
    "order-refund-#{@options['id']}-buyer"

  change_delivery_code: () ->

    code = @$("input:text.delivery_code").val()
    button = @$('.page-header input.delivered')
    if _.isEmpty(code)
      button.addClass("disabled")
    else
      button.removeClass("disabled")

  toggle_panel: (option) ->
    @$(".connect").toggle("slow")

  afterDelivered: (event, from, to, msg) ->
    code = @$("input:text.delivery_code").val()
    logistics_company_id = @$("select[name=logistics_company_id]").val()
    if _.isEmpty(code) && _.isEmpty(logistics_company_id)
      @slideAfterEvent(event)
    else
      url = @transaction.urlRoot
      @transaction.fetch(
        url: "#{url}/update_delivery",
        type: 'POST',
        data: {delivery_code: code, logistics_company_id: logistics_company_id},
        success: () =>
          @slideAfterEvent(event)
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



root.OrderRefundCard = OrderRefundCard