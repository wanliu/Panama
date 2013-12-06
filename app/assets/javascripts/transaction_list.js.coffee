
root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}/dialog",
      success: callback
    )

class TransactionDialogView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)
    @$el.on "hidden", _.bind(@hidden, @)
    @$el.on "shown", _.bind(@shown, @)

    @$el.modal()

  hidden: () ->
    $("body").removeClass(@bodyClass)
    @remove()

  shown: () ->
    $("body").addClass(@bodyClass)

  render: () ->
    @$el

class DisplayDialogView extends Backbone.View
  bodyClass: "noScroll"

  events: {
    "click .more" : "more"
  }

  more: () ->
    @model.load_template (data) =>
      @view = new TransactionDialogView(
        el: $(data).appendTo("body")[0],
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
      view = new DisplayDialogView(
        model: model
        el: $(el))

  bindView: (view) ->


