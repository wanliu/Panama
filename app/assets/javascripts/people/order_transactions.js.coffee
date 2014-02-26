#= require transactions/2columns_viewport
#= require people/transaction_card

root = (window || @)

class TransactionView extends CardItemView
  returned_state: false

  events: {
    "click .btn_delete" : "destroy"
    "click .actions .returned-event" : "returned"
    "click .actions .delay-sign-event" : "delay_sign"
  }
  initialize: (options) ->
    _.extend(@, options)
    super 
    @model.bind("dispose", _.bind(@dispose, @))
    @model.bind("removeReturned", _.bind(@removeReturned, @))      

  get_register_view: () ->
    view = new TransactionCard({
      el: @$(".full-mode .transaction")
    })
    view.transaction.bind("change:state", @card_change_state, @)
    @toggleReturned(view) if @returned_state

    view

  toggleReturned: (view) ->
    view.$(".returned_panel").slideToggle()   

  card_change_state: () ->
    unless _.isEmpty(@card)
      @set_state(@card.transaction.get("state"))
      @model.set(
        state_title: @card.transaction.get("state_title"))
      @_change_state()

    super

  destroy: (event) ->
    if confirm("要取消这笔交易吗?")
      @model.destroy(
        success: (model, data) => @remove()
      )

    false

  returned: () ->
    $operator = @$(".actions .operator")
    if $operator.hasClass("open")      
      $operator.click()
      if _.isEmpty(@card)
        @returned_state = true
      else
        if @card.$(".returned_panel").css("display") == "none"
          @toggleReturned(@card)
          
    else
      @toggleReturned(@card) unless _.isEmpty(@card) 

  removeReturned: () ->   
    @$(".actions .operator").remove()

  delay_sign: () ->  
    url = "#{@model.url()}/delay_sign"
    $.ajax(
      url: url
      type: 'POST'
      dataType: "JSON"
      success: () =>
        pnotify(text: "订单已经延时3天收货期！")

      error: (data) =>
        ms = JSON.parse(data.responseText)
        pnotify(text: ms.join("<br />"), type: "error")
    )

  dispose: () ->
    $.ajax(
      url: "#{@model.url()}/operator",
      type: 'GET',
      success: (data) =>
        $(".actions ul", @$header).prepend(data)
    )

  _change_state: () ->
    @$(".actions .delay-sign-event").parent().remove() if @model.get("state") == "complete"


class root.OrderTransactions extends CardItemListView

  initialize: (options) ->
    @columns_options = {
      secondContainer: ".order-detail",
      spaceName: "order"
    }

    super options

    @monitor_realtime()

  add_one: (elem, model) ->

    @monitor_state model.id    
    new TransactionView(
      model: model,
      el: elem
    )

  reset: () ->
    _.each @$(".orders>.card_item"), (el) => 
      @add_elem(el)


  monitor_realtime: () ->
    @client.monitor "/transactions/dispose", (data) =>
      @dispose(data)

  monitor_state: (order_id) ->
    @client.monitor "/transactions/#{order_id}/change_state", (data) =>
      @change_state data

    @client.monitor "/transactions/#{order_id}/change_info", (data) =>
      @change_total(data)

  change_total: (data) ->
    model = @collection.get(data.order_id)
    model.set(data.info) unless _.isEmpty(model)

  change_state: (data) ->
    model = @collection.get(data.order_id)
    unless _.isEmpty(model)
      model.set({
        state: data.state,
        event: data.event,
        state_title: data.state_title})

    model.trigger("removeReturned") if data.state == "waiting_refund"


  dispose: (data) ->
    model = @collection.get(data.order_id)
    model.trigger("dispose") unless _.isEmpty(model) 
