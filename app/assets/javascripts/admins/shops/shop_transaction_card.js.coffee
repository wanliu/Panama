define ['jquery', 'backbone', "lib/transaction_card_base", 'lib/state-machine', 'exports'],
    ($, Backbone, Transaction, StateMachine, exports) ->

        class ShopTransactionCard extends Transaction.TransactionCardBase

            events:
                "click .page-header .btn"   : "clickAction"
                "click button.close"        : "closeThis"
                "click .detail"        : "toggleItemDetail"

            states:
                initial: 'none'

                events:  [
                    { name: 'refresh',       from: 'order',             to: 'waiting_paid' },
                    { name: 'refresh',       from: 'waiting_paid',      to: 'waiting_delivery' },
                    { name: 'delivered',     from: 'waiting_delivery',  to: 'waiting_sign' }, # only for development
                    { name: 'back',          from: 'waiting_paid',      to: 'order'         },
                    { name: 'back',          from: 'waiting_delivery',  to: 'waiting_paid' }, # only for development
                    { name: 'back',          from: 'waiting_sign',      to: 'waiting_delivery' }, # only for development

                ]

                callbacks:
                    onenterstate: (event, from, to, msg) ->
                        console.log "event: #{event} from #{from} to #{to}"

            getNotifyName: () ->
                super + "-seller"


            toggleItemDetail: (event) ->
                @$(".item-details").slideToggle()
                false

            leaveWaitingDelivery: (event, from, to, msg) ->
                @slideAfterEvent(event) unless /back/.test event

        exports.ShopTransactionCard = ShopTransactionCard
        exports