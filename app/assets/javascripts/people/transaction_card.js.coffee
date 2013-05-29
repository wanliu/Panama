define ['jquery', 'backbone', 'lib/transaction_card_base',  "lib/state-machine", 'exports', 'lib/chosen.jquery'],
($, Backbone, Transaction, StateMachine, exports) ->

    class TransactionCard extends Transaction.TransactionCardBase
        initialize:() ->
            super
            @hideAddress()

        events:
            "click .page-header .btn"   : "clickAction"
            "click button.close"        : "closeThis"
            "click .address-add>button" : "addAddress"
            "click .item-detail"        : "toggleItemDetail"
            "click .message-toggle"     : "toggleMessage"
            "submit .address-form>form" : "saveAddress"
            "click .chzn-results>li"    : "hideAddress"
            "change select#order_transaction_delivery_type_id" : "selectDeliveryType"

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
                { name: "returned",   from: 'complete',          to: 'apply_refund'}
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

        leaveOrder: (event, from ,to , msg) ->
            @$(".address-form>form").submit()
            @selectDeliveryType()
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
                    @$(".address-form").html(xhr.responseText)
                    @$("#address_province_id option:first", ".address-form").attr("selected", true)
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

    exports.TransactionCard = TransactionCard
    exports