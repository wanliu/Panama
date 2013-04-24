define ['jquery', 'backbone', "lib/state-machine", "lib/state-view", "lib/jsclock-0.8", 'exports'], ($, Backbone, StateMachine, StateView, n$, exports) ->


    class ShopTransactionCard extends StateView.AbstructStateView

        states:
            initial: 'none'

            events:  [
                { name: 'buy',   from: 'order',             to: 'waiting_paid' },
                { name: 'back_order',  from: 'waiting_paid',      to: 'order'        },
                { name: 'paid',  from: 'waiting_paid',      to: 'waiting_delivery' },
                { name: 'back_paid',  from: 'waiting_delivery',  to: 'waiting_paid' }, # only for development
                { name: 'delivered',  from: 'waiting_delivery',  to: 'waiting_sign' }, # only for development
                { name: 'back_deliver',  from: 'waiting_sign',  to: 'waiting_delivery' }, # only for development

            ]

            callbacks:
                onenterstate: (event, from, to, msg) ->
                    console.log "event: #{event} from #{from} to #{to}"


    exports.ShopTransactionCard = ShopTransactionCard
    exports