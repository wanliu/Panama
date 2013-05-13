#处理订单

define ["jquery", "backbone", "lib/realtime_client"],
($, Backbone, Realtime) ->

  class TransactionList extends Backbone.Collection

  class TransactionEvent extends Backbone.View
    events: {
      "click .dispose" : "dispose"
    }

    initialize: (options) ->
      _.extend(@, options)

    dispose: () ->
      $.ajax(
        url: @remote_url(),
        type: "POST",
        success: (template, xhr) =>
          @show_tran template
      )

    show_tran: (template) ->
      first_tran_el = @first_transaction()
      if first_tran_el.length <= 0
        @tran_panel.append(template)
      else
        first_tran_el.before(template)

      @tran_card @first_transaction()
      @remove()

    remove: () ->
      @trigger("remove_tran", @model.id)
      super

    first_transaction: () ->
      @tran_panel.find(">.transaction")

    remote_url: () ->
      "/shops/#{@shop_name}/admins/transactions/#{@model.id}/dispose"

  class TransactionDispose extends Backbone.View

    initialize: (options) ->
      _.extend(@, options)
      @transactions = new TransactionList()
      @init_el()
      @load_untrans()

    add_data: (model) ->


    init_el: () ->
      @$tbody = @$("tbody")

    load_untrans: () ->
      trs = @$tbody.find(">tr")
      _.each trs, (tr) =>
        model = @get_transaction($(tr))
        @transactions.add model
        @bind_transaction_event @transactions.get(model.id), $(tr)

      @notice_msg()

    bind_transaction_event: (model, tr) ->
      tran_view = new TransactionEvent(_.extend({}, @tranOpts ,
        {el: tr, model: model, shop_name: @shop_name}))
      tran_view.bind("remove_tran", _.bind(@remove_tran, @))

    get_transaction: (tr) ->
      id = tr.attr("data-value-id")
      {id: id}

    remove_tran: (id) ->
      @transactions.remove @transactions.get id
      @notice_msg()

    notice_msg: () ->
      if @transactions.length <= 0
        @$tbody.append("<tr>
          <td colspan='7' style='text-align:center;'>暂时没未处理单</td>
        </tr>")

