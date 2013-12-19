root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}/page",
      success: callback
    )
class Transactions extends Backbone.Collection
  model: Transaction


class DisplayDialogView extends Backbone.View
  bodyClass: "noScroll"

  events: {
    "click .summarize" : "more"
  }

  initialize: () ->
    @$summar = @$(".summarize")
    @$detail = @$(".detail")
    @$el = $(@el)
    @model.bind("change:summar_display", _.bind(@detail_display, @))

  more: () ->
    state = @model.get("summar_display")
    console.log(state)
    @model.set(summar_display: !state)

  load_template: () ->
    @$el.addClass("active")
    if _.isEmpty(@template)
      @model.load_template (data) =>
        @template = data
        @$detail.html(@template)
        @mini_display () =>
          @trigger("bind_view", @)
    else
      @mini_display()

  mini_display: (callback = () ->) ->
    @$summar.addClass "mini"
    @trigger("off_details", @model)
    @$detail.slideDown "fast", () =>
      callback()

  detail_display: () ->
    if @model.get("summar_display")
      @$el.removeClass("active")
      @$detail.slideUp "fast", () =>
        @$summar.removeClass "mini"
    else
      @load_template()

    console.log("id:#{@model.id}, state: #{@model.get("summar_display")}")

class root.TableListView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @transactions = new Transactions()
    @transactions.url = @remote_url
    @transactions.bind("add", @addView, @)
    @load_view()

  addView: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    view = new DisplayDialogView(
      model: model,
      el: elem)
    view.bind("bind_view", _.bind(@bindView, @))
    view.bind("off_details", _.bind(@off_details, @))

  load_view: () ->
    _.each @$(".item"), (el) =>
      @transactions.add(
        summar_display: true,
        elem: $(el),
        id: $(el).attr('data-value-id'))

  off_details: (model) ->
    for m in @transactions.models
      m.set(summar_display: true) unless m.id == model.id


  bindView: (view) ->



