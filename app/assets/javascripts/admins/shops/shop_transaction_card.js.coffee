define ['jquery', 'backbone', "lib/transaction_card_base", 'lib/state-machine', 'exports'],
    ($, Backbone, Transaction, StateMachine, exports) ->
        class ShopTransactionCard extends Transaction.TransactionCardBase
            initialize:() ->
                super
                @filter_delivery_code()

            events:
                "click .page-header .btn" : "clickAction"
                "click button.close"      : "closeThis"
                "click .detail"           : "toggleItemDetail"
                "click .message-toggle"   : "toggleMessage"
                "keyup .delivery_code"    : "filter_delivery_code"

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

                    onchangestate: (event, from, to) ->
                        @changeProgress()

            getNotifyName: () ->
                super + "-seller"


            toggleItemDetail: (event) ->
                @$(".item-details").slideToggle()
                false

            toggleMessage: (event) ->
                @$("iframe", ".transaction-footer").slideToggle()

            leaveWaitingDelivery: (event, from, to, msg) ->
                @slideAfterEvent(event) unless /back/.test event

            beforeDelivered: (event, from, to, msg) ->
                @save_delivery_code()

            filter_delivery_code: () ->
                delivery_code = @$("input:text.delivery_code").val()
                button = @$(".delivered")
                if delivery_code == ""
                    button.addClass("disabled")
                else
                    button.removeClass("disabled")

            save_delivery_code: () ->
                delivery_code = @$("input:text.delivery_code").val()
                return if delivery_code == ""

                urlRoot = @transaction.urlRoot
                @transaction.fetch(
                    url: "#{urlRoot}/delivery_code",
                    type: "PUT",
                    data: {delivery_code: delivery_code}
                )


        exports.ShopTransactionCard = ShopTransactionCard
        exports