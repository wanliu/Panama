#= require jquery
#= require backbone
#= require lib/transaction_card_base
#= require lib/state-machine
#= require lib/chosen.jquery

class TransactionCard extends TransactionCardBase
    initialize:() ->
        super
        @urlRoot = @transaction.urlRoot
        @body = @$(".transaction-body")

    events:
        "click .page-header .btn"   : "clickAction"
        "click button.close"        : "closeThis"
        "click .address-add>button" : "addAddress"
        "click .item-detail"        : "toggleItemDetail"
        "click .message-toggle"     : "toggleMessage"
        "submit .address-form>form" : "saveAddress"
        "click .chzn-results>li"    : "hideAddress"
        "change select.order_delivery_type_id" : "selectDeliveryType"

    states:
        initial: 'none'

        events:  [
            { name: 'buy',        from: 'order',             to: 'waiting_paid' },
            { name: 'paid',       from: 'waiting_paid',      to: 'waiting_delivery' },
            { name: 'delivered',  from: 'waiting_delivery',  to: 'waiting_sign' },
            { name: 'sign',       from: 'waiting_sign',      to: 'evaluate' },
            { name: 'back',       from: 'waiting_paid',      to: 'order' },
            { name: 'back',       from: 'waiting_delivery',  to: 'waiting_paid' }, # only for development
            { name: 'back',       from: 'waiting_sign',      to: 'waiting_delivery' }, # only for development
            { name: "returned",   from: 'waiting_delivery',  to: 'apply_refund'},
            { name: "returned",   from: 'waiting_sign',      to: 'apply_refund'},
            { name: "returned",   from: 'complete',          to: 'apply_refund'},
            { name: 'transfer',   from: 'waiting_transfer',  to: 'waiting_audit' },
            { name: 'confirm_transfer', from: 'waiting_audit_failure', to: 'waiting_audit' }
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

    toggleMessage: (event) ->
        @$("iframe", ".transaction-footer").slideToggle()

    leaveWaitingTransfer: (event, from, to, msg) ->
        @create_transfer_info(event)

    leaveWaitingAuditFailure: (event, from, to, msg) ->
        @create_transfer_info(event)

    leaveOrder: (event, from ,to , msg) ->
        @$(".address-form>form").submit()
        StateMachine.ASYNC

    leaveWaitingDelivery: (event, from, to, msg) ->
        @slideAfterEvent(event) if /returned/.test event

    leaveWaitingPaid: (event, from, to, msg) ->
        @slideAfterEvent(event) unless /back/.test event

    beforeSign: (event, from, to, msg) ->
        @slideAfterEvent(event)

    saveAddress: (event) ->
        form = @$(".address-form>form")
        params = form.serialize()
        url = form.attr("action")
        $.post(url, params)
            .success (xhr, data, status) =>
                @transition()
                @slideAfterEvent('buy')
            .error (xhr, status) =>
                @notify("错误信息", '请填写完整的信息！', "error")
                @alarm()
                @transition.cancel()
        false

    selectDeliveryType: () ->
        url = @transaction.urlRoot
        delivery_type_id = @$("select#order_transaction_delivery_type_id").val()
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
        form = @body.find("form.transfer_sheet")
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

exports.TransactionCard = TransactionCard
exports