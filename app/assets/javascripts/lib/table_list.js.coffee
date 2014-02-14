root = (window || @)

class Transaction extends Backbone.Model

  loadTemplate: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}/page",
      success: callback
    )

class Transactions extends Backbone.Collection
  model: Transaction


class FullOrMiniView extends Backbone.View
  bodyClass: "noScroll"

  detail: ".full-mode"
  open: ".open"

  events:
    "click": "show"

  initialize: () ->
    @$summar = @$(@open)
    @$detail = @$(@detail)
    @$el = $(@el)
    @$(@open).bind("click", @more)
    @model.bind("change:full_mode", @toggleDisplay)
    @$parentList = @model.get('listView')

  show: () =>
    unless @$el.hasClass('active')
      @$el.addClass("active")

      setTimeout () =>
        @more()
      , 300

  more: () =>
    @model.set('full_mode': !@model.get("full_mode"))

  loadTemplate: () ->
    if @$detail.children() > 0
      @$detail.slideDown "fast"
    else
      @model.loadTemplate (data) =>
        # @$summar.addClass "mini"
        @$detail.html(data)
        @trigger("minimum", @model)
        @$detail.slideDown "fast", () =>
          @trigger("bind_view", @)

  toggleDisplay: () =>
    @$el.toggleClass("opened")

    if @model.get("full_mode")
      @$el.removeClass("active")
      @$detail.slideUp "fast", () =>
        @$summar.removeClass "mini"
        @wait_tag()
    else
      @loadTemplate()

  wait_tag: () ->
    @$el.removeClass("waiting")

class root.TableListView extends Backbone.View

  child: ".item"

  events:
    "enter_3d": "enter3D"
    "leave_3d": "leave3D"

  initialize: () ->
    _.extend(@, @options)
    @transactions = new Transactions()
    @transactions.url = @remote_url
    @transactions.bind("add", @addView, @)
    @loadView()

  addView: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    view = new FullOrMiniView(
      model: model,
      el: elem)
    view.bind("bind_view", _.bind(@bindView, @))
    view.bind("minimum", _.bind(@minimum, @))

  loadView: () ->
    _.each @$(@child), (el) => @add(el)

  add: (item) ->
    @transactions.add(
      full_mode: true,
      elem: $(item),
      listView: @,
      id: $(item).attr('data-value-id'))

  minimum: (model) ->
    for m in @transactions.models
      m.set(full_mode: true) unless m.id == model.id

  bindView: (view) ->

  enter3D: () ->
    @$(@el3d).addClass("_3d")

  leave3D: () ->
    @$(@el3d).removeClass("_3d")


