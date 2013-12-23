root = (window || @)

class Transaction extends Backbone.Model

  loadTemplate: (callback = () ->) ->
    $.ajax(
      url: "#{@url()}/page",
      success: callback
    )

class Transactions extends Backbone.Collection
  model: Transaction

class TransactionTwoColumnsViewport extends Backbone.View

  el: ".transaction-list"
  child: ".order_item"
  orderList: ".left-column"
  contrainer: ".order-viewport"
  leftSide: "#people-sidebar"
  secondContainer: ".order-detail"
  leftClass: "float"
  rightClass: ""

  initialize: (@options) ->
    _.extend(@, @options)
    @models = new Transactions
    @models.url = @remote_url
    @models.bind("add", @addView, @)
    @rows = []
    @inLayout = false
    @$contrainer = @$(@contrainer)
    @$orderList = @$(@orderList)
    @$secondContainer = @$(@secondContainer)
    @$orders = @$(".orders")
    @loadView()

  getCurrentTransaction: () ->

  loadView: () ->
    @$(@child).each (i, ele) =>
      model = new Transaction(
        full_mode: true,
        elem: $(ele),
        listView: @,
        id: $(ele).attr('data-value-id')
      )

      @models.add(model)

  addView: (model) ->
    elem = model.get("elem")
    delete model.attributes.elem

    rowView = new MiniRow2ColView({
      el: elem,
      parentView: @,
      model: model
    })
    rowView.bind("registerView", _.bind(@registerView, @))

    @rows.push rowView

  activeRowView: (view, callback) =>
    @exceptView(view)

    @enterColumnsLayout () =>

      view.active()

      @moveToDetail view, () =>
        callback()


  setupLeftColumn: () ->
    @$orders.slimScroll(height: $(window).height())
    @$orders.on("mouseleave", @hideLeftColumn)
    $(".content").mousemove (e) =>
      if e.clientX < 25
        @showLeftColumn()


  hideLeftColumn: () =>
    @$orderList.css({
      'left': -400
    })

  showLeftColumn: () =>
    @$orderList.css({
      'left': 0
    })

  moveToDetail: (view, callback) =>
    @currentView = view
    el = view.$el
    @insertIndex = el.index()

    posTarget = @$secondContainer.position()
    widthTarget = @$secondContainer.width()

    el
      .attr('style', '')
      .appendTo(@$secondContainer)
      .css
        'margin-left': 200
        'opacity': 0


    callback()


  restoreFromDetail: () =>

    if @currentView?
      el = @currentView.$el
      target = @$(@child).get(@insertIndex)
      $target = $(target)
      posTarget = $target.position()
      widthTarget = $target.width()

      el.insertBefore($target)
      el.attr('style', '')

  enterColumnsLayout: (callback) =>
    unless @inLayout
      @inLayout = true
      @$sidebar ||= new MiniLeftSideView({
        el: @leftSide,
        exitCallback: @exitLayout})
      @$sidebar.buildMenu()
      @$sidebar.mini()

      @$orderList
        .removeClass('span12')
        .css({
          'left': 0
          })
        .addClass(@leftClass)

      @$secondContainer
        .addClass(@rightClass)
        .addClass('flat')

      @setupLeftColumn()

      setTimeout @hideLeftColumn, 2000


    if @currentView?
      @currentView.miniMode()
    # el = @$secondContainer.find(@child)
    # if el.length > 0
    @restoreFromDetail()

    callback()

  exitLayout: () =>
    @$orderList
      .removeClass(@leftClass)
      .addClass('span12')

    @$secondContainer
      .removeClass(@rightClass)

    if @currentView?
      @currentView.miniMode()

    @restoreFromDetail()

    @$orders.slimScroll(destroy: true)
    @$orders.attr('style', '')

    @inLayout = false

  exceptView: (view) ->
    @except = view

  registerView: (view) ->


class MiniRow2ColView  extends Backbone.View

  events:
    "click .open": "openView"
    # "click": "toggleView"

  initialize: (@options) ->
    _.extend(@, @options)
    @$detail = @$('.full-mode')

  toggleView: () =>
    @openView()

  openView: () ->
    @activeRowView()

  activeRowView: () ->
    if @parentView?
      @parentView.activeRowView @, () =>
        if @$detail.is(":empty")
          @model.loadTemplate (data) =>
            @$detail.html(data)
            @trigger("registerView", @)
            @fullMode()
        else
          @fullMode()

  fullMode: () ->
    @$(".order_item_row").hide()
    @$detail.show()

    @$el
      .css
        'margin-left': 0
        'opacity': 1


  miniMode: () ->
    @$detail.hide()
    @$(".order_item_row").show()

  saveSize: () =>
    @width = @$el.width()
    @height = @$el.height()

  restoreSize: () =>

  active: () =>
    @threeD()

    @$el
      # .removeClass('threeD')
      .addClass("active")

    @parentView.hideLeftColumn()
      # .css({
      #   "-webkit-transform": "translate3d(0px, 0px, 0px) rotateX(0deg)",
      #   "-moz-transform": "translate3d(0px,0px, 0px) rotateX(0deg)",
      #   "transform": "translate3d(0px, 0px, 0px) rotateX(0deg)"
      #   })

  normal: () =>
    @$el
      .removeClass('threeD')
      .css({
        "-webkit-transform": "translate3d(0px, 0px, 0px) rotateX(0deg)",
        "-moz-transform": "translate3d(0px,0px, 0px) rotateX(0deg)",
        "transform": "translate3d(0px, 0px, 0px) rotateX(0deg)"
      })


  threeD: () =>
    @saveSize()
    @$el
      .addClass("threeD")
      .removeClass("active")


root.TransactionTwoColumnsViewport = TransactionTwoColumnsViewport
