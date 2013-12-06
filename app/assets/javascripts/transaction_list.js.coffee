
root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    @fetch(
      url: "#{@url()}/page",
      dataType: "html",
      success: callback
    )
class TransactionBaseView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)
    @$el.html(@template)

  render: () ->
    @$el

class TransactionDialogView extends Backbone.View
  bodyClass: "noScroll"

  events: {
    "click .more" : "more"
  }

  initialize: () ->
    @$dialog = $("#order_dialog")
    @$dialog.on "hidden", _.bind(@hidden, @)
    @$dialog.on "shown", _.bind(@shown, @)

  more: () ->
    @model.load_template (m, data) =>
      $(".title", @$dialog).html("编号：#{@model.get('number')}订单")
      @view = new TransactionBaseView(
        model: @model,
        template: data)
      $(".modal-body", @$dialog).html(@view.render())
      @trigger("bind_view", @view)
      @$dialog.modal()

  hidden: () ->
    $("body").removeClass(@bodyClass)

  shown: () ->
    $("body").addClass(@bodyClass)


class root.TransactionListView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @load_view()

  render: () ->

  load_view: () ->
    _.each @$(".item"), (el) =>
      model = new Transaction({
        number: $(el).attr("data-value-number"),
        id: $(el).attr('data-value-id')})

      model.urlRoot = @remote_url
      view = new TransactionDialogView(
        model: model
        el: $(el))
      view.bind("bind_view", _.bind(@bindView, @))

  bindView: (view) ->


