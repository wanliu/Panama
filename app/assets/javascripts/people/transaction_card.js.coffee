define ['jquery', 'backbone', 'lib/transaction_card_base',  "lib/state-machine", 'exports', 'lib/chosen.jquery'], 
($, Backbone, Transaction, StateMachine, exports) ->

    class TransactionCard extends Transaction.TransactionCardBase

        events:
            "click .page-header .btn"   : "clickAction"
            "click button.close"        : "closeThis"
            "click .address-add>button" : "toggleAddress"
            "click .item-detail"        : "toggleItemDetail"
            "submit .address-form>form" : "saveAddress"
            "click .chzn-results>li"    : "selectAddress"
            "change .delivery-select"   : "selectDeliveryType"

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

            ]

            callbacks:
                onchangestate: (event, from, to) ->
                    @changeProgress()
                    # console.log "event: #{event} from #{from} to #{to}"
        
        initialize:() ->
            super
            $(".address-panel").slideUp()

        getNotifyName: () ->
            super + "-buyer"

        beforeBack: (event, from ,to ) ->
            @slideBeforeEvent('back')
            true

        toggleAddress: (event) ->
            @$(".address-panel").slideToggle()
            @$el.find("abbr:first").trigger("mouseup")
            false

        toggleItemDetail: (event) ->
            @$(".item-details").slideToggle()
            false

        # 状态事件
        # enterOrder: (event, from, to, msg ) ->
        #     @$(".address-form>form").submit(_.bind(@saveAddress, @))

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
                    @$("#address_province_id option:first", ".address-form").attr("selected", true)
                    @alarm()
                    @transition.cancel()
                    false
            false

        selectAddress: () ->
            @$(".address-panel").slideUp()

        selectDeliveryType: () ->
            options_el = @$el.find(".delivery-select select")
            delivery_type_id = options_el.find("option:selected").val()
            url = "#{options_el.attr('action')}?delivery_type_id=#{delivery_type_id}"
            $.get(url)
                .success (data) =>
                    @$el.find("#order_transaction_delivery_price").val(data);
                    @$el.find(".delivery_price").html("¥ #{parseFloat(data).toFixed(2)}");

    exports.TransactionCard = TransactionCard
    exports