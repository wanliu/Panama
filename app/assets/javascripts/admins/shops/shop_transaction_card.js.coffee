#= require 'jquery'
#= require 'backbone'
#= require 'lib/transaction_card_base'
#= require 'lib/state-machine'

exports = window || @
class ShopTransactionCard extends TransactionCardBase

    initialize:() ->
        super
        @filter_delivery_code()
        @initMessagePanel()

    events:
        "click .page-header .btn" : "clickAction"
        "click button.close"      : "closeThis"
        "click .detail"           : "toggleItemDetail"
        "click .message-toggle"   : "toggleMessage"
        "keyup .delivery_code"    : "filter_delivery_code"

    states:
        initial: 'none'

        events:  [
            { name: 'refresh',          from: 'order',             to: 'waiting_paid' },
            { name: 'refresh',          from: 'waiting_paid',      to: 'waiting_delivery' },
            { name: 'audit_transfer',   from: 'waiting_audit',     to: 'waiting_delivery'},
            { name: 'audit_failure',    from: 'waiting_audit',     to: 'waiting_audit_failure'},
            { name: 'delivered',        from: 'waiting_delivery',  to: 'waiting_sign' }, # only for development
            { name: 'back',             from: 'waiting_paid',      to: 'order'         },
            { name: 'back',             from: 'waiting_delivery',  to: 'waiting_paid' }, # only for development
            { name: 'back',             from: 'waiting_sign',      to: 'waiting_delivery' }, # only for development

        ]

        callbacks:
            onenterstate: (event, from, to, msg) ->
                console.log "event: #{event} from #{from} to #{to}"

    getNotifyName: () ->
        super + "-seller"


    toggleItemDetail: (event) ->
        @$(".item-details").slideToggle()
        false

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