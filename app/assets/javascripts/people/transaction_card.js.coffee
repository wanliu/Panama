define ['jquery', 'backbone', 'lib/transaction_card_base',  "lib/state-machine", 'exports'], ($, Backbone, Transaction, StateMachine, exports) ->


    class TransactionCard extends Transaction.TransactionCardBase

        events:
            "click .page-header .btn"   : "clickAction"
            "click button.close"        : "closeThis"
            "click .address-add>button" : "toggleAddress"
            "click .item-detail"        : "toggleItemDetail"

        states:
            initial: 'none'

            events:  [
                { name: 'buy',           from: 'order',             to: 'waiting_paid' },
                { name: 'paid',          from: 'waiting_paid',      to: 'waiting_delivery' },
                { name: 'delivered',     from: 'waiting_delivery',  to: 'waiting_sign' },
                { name: 'sign'     ,     from: 'waiting_sign',      to: 'evaluate' },
                { name: 'back',          from: 'waiting_paid',      to: 'order' },
                { name: 'back',          from: 'waiting_delivery',  to: 'waiting_paid' }, # only for development
                { name: 'back',          from: 'waiting_sign',      to: 'waiting_delivery' }, # only for development

            ]

            callbacks:
                onenterstate: (event, from, to, msg) ->
                    console.log "event: #{event} from #{from} to #{to}"

        getNotifyName: () ->
            super + "-buyer"

        beforeBack: (event, from ,to ) ->
            @slideBeforeEvent('back')
            true

        toggleAddress: (event) ->
            @$(".address-panel").slideToggle()
            false

        toggleItemDetail: (event) ->
            @$(".item-details").slideToggle()
            false

        ############################################################################
        # 状态事件
        enterOrder: (event, from, to, msg ) ->
            @$(".address-form>form").submit(_.bind(@saveAddress, @))

        leaveOrder: (event, from ,to , msg) ->
            @$(".address-form>form").submit()
            StateMachine.ASYNC

        enterWaitingDelivery: (event, from, to, msg) ->
            @$(".clock").jsclock();

        leaveWaitingPaid: (event, from, to, msg) ->
            @slideAfterEvent(event) unless /back/.test event


        saveAddress: (event) ->
            params = @$(".address-form>form").serialize()
            url = @$(".address-form>form").attr("action")
            $.post(url, params)
                .success (xhr, data, status) =>
                    @transition()
                    @slideAfterEvent('buy')
                    false
                .error (xhr, status) =>
                    @$(".address-form").html(xhr.responseText)
                    @$(".address-form>form").submit(_.bind(@saveAddress, @))
                    @alarm()
                    @transition.cancel()
                    false
            false

    exports.TransactionCard = TransactionCard
    exports