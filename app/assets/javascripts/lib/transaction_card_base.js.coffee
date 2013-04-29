define ['jquery', 'backbone', "lib/state-machine", "lib/state-view", "lib/jsclock-0.8", 'lib/realtime_client', 'exports'],
    ($, Backbone, StateMachine, StateView, _a, RealtimeClient, exports) ->

        class TransactionCardBase extends StateView.AbstructStateView


            initialize:(@option) ->
                super
                @options['initial']   ?= @$el.attr('state-initial')
                @options['id']        ?= @$el.attr('state-id')
                @options['url']       ?= @$el.attr('state-url')
                @options['event_url'] ?= @$el.attr('state-event-url')

                @rt_options = @options['realtime']
                if @rt_options.url?
                    @realtime = RealtimeClient.client(@rt_options.url)
                    @realtime.monitor_event @getNotifyName(), @rt_options.token, _.bind(@stateChange, @)
                # @$el.bind('click', @activeThis)

            getNotifyName: () ->
                "transaction-#{@options['id']}"

            clickAction: (event) ->
                btn = $(event.target)
                if !btn.hasClass("disabled")
                    event_name = btn.attr('event-name')
                    @[event_name].call(@)
                false


            stateChange: (data) ->
                console.log data.name
                event_name = data.event || "refresh"
                @[event_name].call(@)
                $.get @url(), (data) =>
                    @effect 'flipInY'

                    setTimeout () =>
                        # @$el.wrap("<p>")
                        # p = @$el.parent()
                        # p.html(data)
                        # @$el.unwrap()
                        html = $(data)
                        @$el.replaceWith(html)
                        @$el = html

                        @delegateEvents()
                        # .html(data).unwrap()
                    , 300

                    # @$el.addClass("animated flipInY")


            closeThis: (event) ->
                if confirm("要取消这笔交易吗?")
                    if Modernizr.cssanimations?
                        $(@el).addClass("animated fadeOutUp")
                        setTimeout () =>
                            @$el.hide()
                        , 1300
                    else
                        $(@el).fadeOut()

            eventUrl: (event) ->
                @options['event_url'] + "/#{event}"

            url: () ->
                @options['url']

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

                overSlide = () =>
                    $side1.unwrap()
                          .remove()
                    @$el = $side2.find(">.transaction")
                    @delegateEvents()
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

            effect: (effect_name, handle) ->
                if Modernizr.cssanimations?
                    classies = "animated #{effect_name}"
                    @$el.addClass(classies)
                    setTimeout () =>
                        @$el.removeClass(classies)
                    , 1300
                else
                    handle.call(@) if _(handle).isFunction()

            alarm: () ->
                effect = "bounce"
                @$el.removeClass("animated #{effect}").addClass("animated #{effect}");
                wait = window.setTimeout () =>
                    @$el.removeClass("animated #{effect}")
                , 1300

        exports.TransactionCardBase = TransactionCardBase
        exports