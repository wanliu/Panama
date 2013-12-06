
root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}/dialog",
      success: callback
    )

class TransactionBaseView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)
    @$dialog = @$(".order_dialog")
    @$dialog.on "hidden", _.bind(@hidden, @)
    @$dialog.on "shown", _.bind(@shown, @)

  hidden: () ->
    $("body").removeClass(@bodyClass)
    @$dialog.css(
      "overflow": "visible",
      "display": "block"
    )

  shown: () ->
    $("body").addClass(@bodyClass)

  render: () ->
    @$el

class TransactionDialogView extends Backbone.View
  bodyClass: "noScroll"

  events: {
    "click .more" : "more"
  }

  more: () ->
    @model.load_template (data) =>
      @view = new TransactionBaseView(
        el: $(data).appendTo("body"),
        model: @model)


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

  bindView: (view) ->


