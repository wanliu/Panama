#= require lib/transaction_card_base
#= require lib/chosen.jquery
#= require lib/order_export

root = window || @

class TransactionCard extends TransactionCardBase
  initialize:() ->
    super
    @urlRoot = @transaction.urlRoot
    @initMessagePanel()
    @countdown()

  events:
    "click .transaction-actions .btn_event"  : "clickAction"
    "click .btn_delete"              : "closeThis"
    "click .address-add>button"      : "addAddress"
    "click .item-detail"             : "toggleItemDetail"
    "submit .address-form>form"      : "saveAddress"
    "click .chzn-results>li"         : "hideAddress"
    "keyup .code>input:text"         : "show_transfer_code"

  states:
    initial: 'none'

    events:  [
      { name: 'online_payment',         from: 'order',                  to: 'waiting_paid' },
      { name: 'bank_transfer',          from: 'order',                  to: 'waiting_transfer' },
      { name: 'paid',                   from: 'waiting_paid',           to: 'waiting_delivery' },
      { name: 'refresh_delivered',      from: 'waiting_delivery',       to: 'waiting_sign' },
      { name: 'refresh_returned',       from: 'waiting_refund',         to: 'refund' },
      { name: 'refresh_returned',       from: 'delivery_failure',       to: 'waiting_refund' },
      { name: 'refresh_returned',       from: 'waiting_delivery',       to: 'waiting_refund' },
      { name: 'refresh_returned',       from: 'waiting_sign',           to: 'waiting_refund' },
      { name: 'refresh_returned',       from: 'complete',               to: 'waiting_refund' },
      { name: 'refresh_audit_transfer', from: 'waiting_audit',          to: 'waiting_delivery'},
      { name: 'refresh_audit_failure',  from: 'waiting_audit',          to: 'waiting_audit_failure'  },
      { name: 'sign',                   from: 'waiting_sign',           to: 'complete' },
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

  initMessagePanel: () ->
    # @setMessagePanel()
    # @message_panel.show()

  leaveWaitingTransfer: (event, from, to, msg) ->
    @create_transfer_info(event)

  leaveWaitingAuditFailure: (event, from, to, msg) ->
    @create_transfer_info(event)

  leaveOrder: (event, from ,to , msg) ->
    @$(".address-form>form").submit()
    StateMachine.ASYNC

  #leaveWaitingDelivery: (event, from, to, msg) ->
  #  @slideAfterEvent(event) if /refresh_delivered/.test event

  leaveWaitingPaid: (event, from, to, msg) ->
    @slideAfterEvent(event) unless /back/.test event

  beforeSign: (event, from, to, msg) ->
    @slideAfterEvent(event)

  saveAddress: (event) ->
    form = @$(".address-form>form")
    params = form.serializeHash()
    manner = @$(".manner_wrap").serializeHash()
    
    if _.isEmpty(params.order_transaction.address_id)
      flag = true
      # 验证填写的地址信息完整性，邮编除外
      _.map params.address, (value, key) =>
        if flag && key isnt 'zip_code' && _.isEmpty(value)
          @notify("错误信息", '请填写完整的地址信息！', "error")
          @back_state()
          flag = false
      return flag unless flag

    if _.isEmpty(manner.pay_type)
      pnotify(text: "请选择支付类型", type:"warning")
      @back_state()
      return false

    if _.isEmpty(manner.transport_type)  
      pnotify(text: "请选择运输方式", type:"warning")
      @back_state()
      return false

    if manner.transport_type == "自定义" &&
    _.isEmpty(manner.delivery_price) && 
    !_.isFinite(manner.delivery_price)

      pnotify(text: "请输入自定义运费！", type:"warning")
      @$("input:text[name='delivery_price']").focus()
      @back_state()
      return false

    params.order_transaction ||= {}
    _.extend(params.order_transaction, manner)

    $.ajax(
      url: form.attr("action"),
      data: params,
      type: "PUT",
      success: (data, xhr, status) =>
        @transition()
        @slideAfterEvent(data.event)

      error: (xhr, status) =>
        try
          ms = JSON.parse(xhr.responseText)
          @notify("错误信息", ms.join("<br />"), "error")
        catch error
          @$(".address-form").html(xhr.responseText)
          @notify("错误信息", '请填写完整的信息！', "error")
        finally
          @back_state()
    )
    false

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
    transfers = form.serializeHash()
    if @validate_transfer(transfers, form)
      @transaction.fetch(
        url: "#{@urlRoot}/transfer",
        data: {transfer: transfers},
        type: 'POST',
        success: (model, data) =>
          @slideAfterEvent(event_name)
        error: (data, xhr, res) =>
          try
            ms = JSON.parse(xhr.responseText)
            @notify("错误信息", ms.join("<br />"), "error")
          catch error
            form.html(xhr.responseText)
            @notify("错误信息", '请确认汇款单信息！', "error")
          finally
            @back_state()
            return false
      )
    else
      @back_state()
      
    false

  show_transfer_code: (event) ->
    code_input = @$("input:text[name=code]")
    if !event.ctrlKey && event.keyCode > 47 && event.keyCode < 106
      code_input.val(code_input.val().replace(/(\w{4})(?=\w)/g,"$1 "))

  realtime_url: () ->
    "/transactions#{super}"   


root.TransactionCard = TransactionCard
