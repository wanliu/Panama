define ['jquery', 'backbone', "lib/state-machine", "lib/state-view", 'exports'], ($, Backbone, StateMachine, StateView, exports) ->


    class TransactionCard extends StateView.AbstructStateView

        events:
            "click .page-header .btn"   : "clickAction"
            "click button.close"        : "closeThis"
            "click .address-add>button" : "toggleAddress"
            "click .item-detail"        : "toggleItemDetail"

        states:
            initial: 'none'

            events:  [
                { name: 'sure',   from: 'order',             to: 'waiting_paid' }
            ]

            callbacks:
                onenterstate: (event, from, to, msg) ->
                    console.log "event: #{event} from #{from} to #{to}"


        clickAction: (event) ->
            @alarm()
            false
            # alert('Yeah , you click me!')


        closeThis: (event) ->
            if confirm("要取消这笔交易吗?")
                if Modernizr.cssanimations?
                    $(@el).addClass("animated fadeOutUp")
                else
                    $(@el).fadeOut()

        toggleAddress: (event) ->
            @$(".address-panel").slideToggle()
            false

        toggleItemDetail: (event) ->
            @$(".item-details").slideToggle()
            false


        enterOrder: (event, from ,to , msg ) ->
            @$(".address-panel").slideToggle()

        alarm: () ->
            effect = "bounce"
            @$el.removeClass("animated #{effect}").addClass("animated #{effect}");
            wait = window.setTimeout () =>
                @$el.removeClass("animated #{effect}")
            , 1300

    exports.TransactionCard = TransactionCard
    exports