#= require lib/transaction_card_base
#= require lib/chosen.jquery

root = window || @

class TransactionCard extends TransactionCardBase
  initialize:() ->
    super
    @urlRoot = @transaction.urlRoot
    @initMessagePanel()

  events:
    "click .page-header .btn"        : "clickAction"
    "click button.close"             : "closeThis"
    "click .address-add>button"      : "addAddress"
    "click .item-detail"             : "toggleItemDetail"
    "click .message-toggle>button"   : "toggleMessage"
    "submit .address-form>form"      : "saveAddress"
    "click .chzn-results>li"         : "hideAddress"
    "change .order_delivery_type_id" : "selectDeliveryType"

  states:
    initial: 'none'

    events:  [
      { name: 'online_payment',         from: 'order',                  to: 'waiting_paid' },
      { name: 'bank_transfer',          from: 'order',                  to: 'waiting_transfer' },
      { name: 'cash_on_delivery',       from: 'order',                  to: 'waiting_delivery' }
      { name: 'paid',                   from: 'waiting_paid',           to: 'waiting_delivery' },
      { name: 'refresh_delivered',      from: 'waiting_delivery',       to: 'waiting_sign' },
      { name: 'refresh_returned',       from: 'waiting_refund',         to: 'refund' },
      { name: 'refresh_returned',       from: 'delivery_failure',       to: 'waiting_refund' },
      { name: 'refresh_returned',       from: 'waiting_delivery',       to: 'waiting_refund' },
      { name: 'refresh_returned',       from: 'waiting_sign',           to: 'waiting_refund' },
      { name: 'refresh_returned',       from: 'complete',               to: 'waiting_refund' },
      { name: 'refresh_audit_transfer', from: 'waiting_audit',          to: 'waiting_delivery'},
      { name: 'sign',                   from: 'waiting_sign',           to: 'evaluate' },
      { name: 'back',                   from: 'waiting_paid',           to: 'order' },
      { name: 'back',                   from: 'waiting_delivery',       to: 'waiting_paid' }, # only for development
      { name: 'back',                   from: 'waiting_sign',           to: 'waiting_delivery' }, # only for development
      { name: "returned",               from: 'waiting_delivery',       to: 'apply_refund' },
      { name: "returned",               from: 'waiting_sign',           to: 'apply_refund' },
      { name: "returned",               from: 'complete',               to: 'apply_refund' },
      { name: 'transfer',               from: 'waiting_transfer',       to: 'waiting_audit' },
      { name: 'confirm_transfer',       from: 'waiting_audit_failure',  to: 'waiting_audit' },
      { name: 'audit_transfer',         from: 'waiting_audit',          to: 'waiting_delivery'},
      { name: 'audit_failure',          from: 'waiting_audit',          to: 'waiting_audit_failure'}
    ]

  getNotifyName: () ->
    super + "-buyer"

  beforeBack: (event, from ,to ) ->
    @slideBeforeEvent('back')
    true

  addAddress: (event) ->
    @$(".address-panel").slideToggle()
    @$el.find("abbr:first").trigger("mouseup")
    false

  toggleItemDetail: (event) ->
    @$(".item-details").slideToggle()
    false

  hideAddress: () ->
    @$(".address-panel").slideUp()

  setMessagePanel: () ->
    @message_panel = @$("iframe", ".transaction-footer")
    height = @$(".transaction-header").parents(".left").innerHeight() - @$(".message-toggle").height()
    @message_panel.height(height)

  initMessagePanel: () ->
    @setMessagePanel()
    @message_panel.show()

  toggleMessage: () ->
    @setMessagePanel()
    @message_panel.slideToggle()
    false

  leaveWaitingTransfer: (event, from, to, msg) ->
    @create_transfer_info(event)

  leaveWaitingAuditFailure: (event, from, to, msg) ->
    @create_transfer_info(event)

  leaveOrder: (event, from ,to , msg) ->
    @$(".address-form>form").submit()
    StateMachine.ASYNC

  #leaveWaitingDelivery: (event, from, to, msg) ->
      #@slideAfterEvent(event) if /refresh_delivered/.test event

  leaveWaitingPaid: (event, from, to, msg) ->
    @slideAfterEvent(event) unless /back/.test event

  beforeSign: (event, from, to, msg) ->
    @slideAfterEvent(event)

  saveAddress: (event) ->
    form = @$(".address-form>form")
    params = form.serialize()
    url = form.attr("action")
    $.post(url, params)
        .success (data, xhr, status) =>
            @transition()
            @slideAfterEvent(data.event)
        .error (xhr, status) =>
            @$(".address-form").html(xhr.responseText)
            @notify("错误信息", '请填写完整的信息！', "error")
            @alarm()
            @transition.cancel()
    false

  selectDeliveryType: () ->
    url = @transaction.urlRoot
    delivery_type_id = @$("select.order_delivery_type_id").val()
    @transaction.fetch(
        url: "#{url}/get_delivery_price",
        data: {delivery_type_id: delivery_type_id},
        type: "POST",
        success: (model, data) ->
            @$("input:hidden.price").val(data.delivery_price)
            @$(".delivery_price").html("¥ #{parseFloat(data.delivery_price).toFixed(2)}")
    )

  validate_transfer: (transfers, form) ->
    state = true
    if _.isEmpty(transfers.person)
        form.find(".person").addClass("error")
        state = false

    if _.isEmpty(transfers.code)
        form.find(".code").addClass("error")
        state = false

    if _.isEmpty(transfers.bank)
        form.find(".bank").addClass("error")
        state = false

    state

  create_transfer_info: (event_name) ->
    body = @$(".transaction-body")
    form = body.find("form.transfer_sheet")
    data = form.serializeArray()
    transfers = {}
    _.each data, (d)  -> transfers[d.name] = d.value

    if @validate_transfer(transfers, form)
        @transaction.fetch(
            url: "#{@urlRoot}/transfer",
            data: {transfer: transfers},
            type: 'POST',
            success: (model, data) =>
                @slideAfterEvent(event_name)
        )
    else
        @alarm()
        @transition.cancel()

root.TransactionCard = TransactionCard
