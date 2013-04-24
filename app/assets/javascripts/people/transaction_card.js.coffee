define ['jquery', 'backbone', "lib/state-machine", "lib/state-view", "lib/jsclock-0.8", 'exports'], ($, Backbone, StateMachine, StateView, n$, exports) ->


    class TransactionCard extends StateView.AbstructStateView

        events:
            "click .page-header .btn"   : "clickAction"
            "click button.close"        : "closeThis"
            "click .address-add>button" : "toggleAddress"
            "click .item-detail"        : "toggleItemDetail"

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

        initialize:(@option) ->
            super
            @$el.bind('click', @activeThis)

        activeThis: () ->

        clickAction: (event) ->
            btn = $(event.target)
            if !btn.hasClass("disabled")
                event_name = btn.attr('event-name')

                url = @eventUrl(event)
                @[event_name].call(@)
            false
            # if event == 'back'
            #     @slideBeforeEvent(event_name)
            # else
            #     @slideAfterEvent(event_name)
            # false

        beforeBackOrder: (event, from ,to ) ->
            @slideBeforeEvent('back')

        beforeBackPaid: (event, from ,to ) ->
            @slideBeforeEvent('back')

        beforeBackDeliver: (event, from ,to ) ->
            @slideBeforeEvent('back')

        closeThis: (event) ->
            if confirm("要取消这笔交易吗?")
                if Modernizr.cssanimations?
                    $(@el).addClass("animated fadeOutUp")
                    setTimeout () =>
                        @$el.hide()
                    , 1300
                else
                    $(@el).fadeOut()

        toggleAddress: (event) ->
            @$(".address-panel").slideToggle()
            false

        toggleItemDetail: (event) ->
            @$(".item-details").slideToggle()
            false

        eventUrl: (event) ->
            @options['event_url'] + "/#{event}"

        slideBeforeEvent: (event) ->
            @slideEvent(event, 'left')

        slideAfterEvent: (event) ->
            @slideEvent(event, 'right')

        slideEvent: (event, direction = 'right') ->

            $.post @eventUrl(event), (data) =>
                @slidePage(data, direction)


        slidePage: (page, direction = 'right') ->
            $side1 = $("<div class='slide-1'></div>")
            $side2 = $("<div class='slide-2'></div>")

            @$el.wrap($("<div class='slide-box'></div>"))
            @$el.wrap($("<div class='slide-container'></div>"))
            @$el.wrap($side1)
            $slideBox = @$el.parents(".slide-box")
            $slideContainer = @$el.parents(".slide-container")
            $side2 = $("<div class='slide-2'></div>").html(page)
            $side1 = @$el
            $slideContainer.append($side2)

            height =  Math.max($side2.height(), $side1.height())
            length = $slideBox.width()
            width = @$el.width()

            $slideBox.height(height)
            $slideBox.width(width)
            $slideContainer.width( width * 2)
            $slideContainer.height( height )

            $side1.width(width)
                  .height($side1.height())

            overSlide = () ->
                $side1.unwrap()
                      .remove()
                $side2.find(">.transaction")
                      .unwrap()
                      .unwrap()
                      .unwrap()


            if direction == 'right'
                $side1.css('float', 'left')
                $side2.width(width)
                      .css('float', 'left')
                $slideBox.animate { scrollLeft: length }, "slow", overSlide
            else
                $side1.css('float', 'right')
                $side2.width(width)
                      .css('float', 'left')
                $slideBox.scrollLeft(length)
                $slideBox.animate { scrollLeft: -length }, "slow", overSlide

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
            @slideAfterEvent(event)

        leaveWaitingDelivery: (event, from, to, msg) ->
            @slideAfterEvent(event)

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


        alarm: () ->
            effect = "bounce"
            @$el.removeClass("animated #{effect}").addClass("animated #{effect}");
            wait = window.setTimeout () =>
                @$el.removeClass("animated #{effect}")
            , 1300

    exports.TransactionCard = TransactionCard
    exports