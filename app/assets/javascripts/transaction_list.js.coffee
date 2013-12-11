
root = (window || @)

class Transaction extends Backbone.Model

  load_template: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}",
      success: callback
    )

class Transactions extends Backbone.Collection

  model: Transaction

class TransactionPanelView extends Backbone.View
  className: "item"
  events: {
    "click .close_panel" : "close"
  }

  initialize: () ->
    @$el = $(@el)
    @$el.html(@close_elem())

  show: (callback = () ->) ->
    @load_template () =>
      callback @$el
      @$el.addClass("active")

  hide: (callback = () ->) ->
    callback @$el
    @$el.removeClass("active")

  load_template: (callback = () ->) ->
    if _.isEmpty(@template)
      @model.load_template (template) =>
        @template = template
        @$el.append(@template)
        callback.call(@)
    else
      callback.call(@)

  render: () ->
    @$el

  close_elem: () ->
    "<button type='button' class='close_panel'>×</button>"

  close: () ->
    @model.set(panel_state: false)


class TransactionView extends Backbone.View
  events: {
    "click" : "show_detail"
  }

  initialize: () ->
    @$el = $(@el)
    @model.bind("change:panel_state", @toggle, @)
    @view = new TransactionPanelView( model: @model )

  show_detail: () ->
    if $(".panel_items>.animate").length <= 0
      @model.set(panel_state: true)

  toggle: () ->
    if @model.get("panel_state")
      @$el.addClass("active")
      @view.show (elem) =>
        @animate {
          elem: elem,
          direction: "right",
          model:  @model
        }
    else
      @$el.removeClass("active")
      @view.hide (elem) =>
        @animate {
          elem: elem,
          direction: "left"}

  animate: (opts) ->
    @trigger("animate", opts)


class root.TransactionListView extends Backbone.View
  left_width: 165
  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)
    @time_ids = []
    @$wrap_items = @$(".wrap_items")
    @$panel_items = @$(".panel_items")
    @collection = new Transactions()
    @collection.url = @remote_url
    @collection.bind("add", @add_view, @)
    @load_view()
    @panel_affix()

  load_view: () ->
    _.each @$(".item"), (el) =>
      @collection.add(
        panel_state: false,
        id: $(el).attr("data-value-id"),
        elem: $(el))

  add_view: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem
    order = new TransactionView(
      el: elem,
      model: model
    )
    order.bind("animate", _.bind(@animate, @))
    @$panel_items.prepend(order.view.render())

  clear_active: (model = null) ->
    unless _.isEmpty(model)
      for m in @collection.models
        m.set(panel_state: false) unless m.id == model.id

  change_mini: () ->
    models = @find_active_item()
    if models.length < 1
      @$el.removeClass("left-mini")

  wrap_animate: () ->
    unless @$el.hasClass("left-mini")
      @$wrap_items.animate {left: -(@$el.outerWidth() - @left_width)}, () =>
        @$wrap_items.css(left: 0)

      @panel_animate()

  panel_animate: () ->
    @$panel_items.css(
      height: @$wrap_items.height(),
      width: @$el.outerWidth() - @left_width,
      left: @$el.outerWidth())
    @$panel_items.addClass("animate")
    @$panel_items.animate {left: @left_width}, () =>
      active = $(".item.active", @$panel_items)
      @$el.addClass("left-mini")
      @$panel_items.removeClass("animate")
      @$panel_items.css(
        height: active.height()
        width: "",
        left: 0)
      @affix()

  animate: (opts) ->
    @clear_active(opts.model)
    if @$el.hasClass("left-mini")
      #@_animate(opts)
    else
      #@wrap_animate()

    @$el.addClass("left-mini")

  _animate: (opts) ->
    @change_mini()
    @$panel_items.css(
      overflow: "hidden")
    opts.elem.addClass('animate')
    left = @item_position(opts.elem, opts.direction)
    opts.elem.animate {left: left}, () =>
      opts.elem.removeClass('animate')
      opts.elem.css(left: 0)
      active = $(".item.active", @$panel_items)
      @$panel_items.css(
        height: active.height,
        overflow: "visible")


  item_position: (elem, direction) ->
    left = elem.outerWidth()
    if direction == "right"
      elem.css(left: left)
      0
    else
      -left

  close: () ->
    @change_mini()

  find_active_item: () ->
    models = @collection.where(panel_state: true)

  panel_affix: () ->
    $(window).on 'scroll.order.affix', () => @affix()

  affix: () ->
    affix = @$panel_items.data("affix")
    affix.checkPosition()
    unless affix.affixed
      width = @$el.outerWidth() - @left_width
      @$panel_items.width(width)
    else
      @$panel_items.width("")







