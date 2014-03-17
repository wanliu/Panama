root = (window || @)

class WorkList extends Backbone.Router

  initialize: (name) ->
    @route "open/:id/#{name}", "open"
    @route "#{name}", "home"

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
  orderList: ".left-column"
  child: ".card_item"
  contrainer: ".order-viewport"
  leftSide: "#people-sidebar"
  secondContainer: ".order-detail"
  leftClass: "float"
  rightClass: ""
  warpClass: ".card_list"
  scrollTop: 0

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
    @$orders = @$(@warpClass)
    @loadView()
    @bindRoute()

  getCurrentTransaction: () ->

  loadView: () ->
    @$(@child).each (i, ele) => @add ele

  add: (elem) ->
    model = new Transaction(
      full_mode: true,
      elem: $(elem),
      listView: @,
      id: $(elem).attr('data-value-id')
    )

    @models.add(model)    
    model

  addView: (model) ->
    @$(".card_list .no_result_notify").remove()
    
    elem = model.get("elem")
    model.set(display: false)
    delete model.attributes.elem

    rowView = new MiniRow2ColView({
      el: elem,
      parentView: @,
      model: model
    })
    rowView.bind("registerView", _.bind(@registerView, @))
    rowView.bind("exitMenu", _.bind(@exitMenu, @))

    @rows.push rowView    

  activeRowView: (view, callback) =>
    @exceptView(view)
    @enterColumnsLayout () =>
      view.active()
      @moveToDetail view, () =>
        callback()

  setupLeftColumn: () ->
    @$orders.slimScroll(
      alwaysVisible: true,
      allowPageScroll: true,
      height: 'auto'
    )
    @$orders.on("mouseleave", @hideLeftColumn)
    $("body").mousemove (e) =>
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
      target = @rows[@insertIndex - 1]
      #$target = row.$el
      #posTarget = $target.position()
      #widthTarget = $target.width()

      if _.isEmpty(target)
        @$orders.prepend(el)
      else
        el.insertAfter(target.$el)

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
    @$orders.slimScroll(
      railVisible: false,
      allowPageScroll: true,
      height: 'auto'
    )
    # @$orders.slimScroll(destroy: true)
    # @$orders.attr('style', '')
    @inLayout = false

  exceptView: (view) ->
    @except = view

  registerView: (view) ->

  bindRoute: () ->
    @route = new WorkList(@spaceName)
    @route.on "route:open", (id) =>
      @scrollTop = @bodyScrollTop()
      model = @models.get(id)
      unless _.isEmpty(model)
        @openView(model)
      else
        @load_item(id)

    @route.on "route:home", () =>     
      model = @find_on()
      model.set(display: false) unless _.isEmpty(model)
      @bodyScrollTop(@scrollTop)            

  bodyScrollTop: (number) ->
    if number?
      setTimeout () =>
        $("body").scrollTop(number)      
      , 100
    else
      top = $("body").scrollTop()
      return top
    
  navigate: (url) ->
    @route.navigate("#{url}#{@spaceName}", trigger: true)

  openView: (id) ->  
    model = @models.get(id)
    unless _.isEmpty(model)
      @clearDisplay()
      model.set({display: true}) 

  clearDisplay: () ->
    @models.each (model) ->
      model.set(display: false)

  find_on: () ->
    @models.where(display: true)[0]

  load_item: (id) ->
    $.ajax(
      url: "#{@remote_url}/#{id}/mini_item"
      success: (data) => 
        item = $(data).appendTo(@$(".left-column .card_list"))
        model = @add(item)            
        model.set({fetch_state: true})
        @openView(model)
      error: (data) =>
        try
          ms = JSON.parse(data.responseText)
          pnotify(text: ms.join("<br />"), type: "warning")
        catch err
          pnotify(text: data.responseText, type: "error")
        finally
          @navigate("")
    )

  exitMenu: () ->
    unless _.isEmpty(@$sidebar)
      model = @find_on()      
      @$sidebar.exitWrap() if _.isEmpty(model)


class MiniRow2ColView  extends Backbone.View

  events:
    "click .card_item_header .open": "_open"
    "click .card_item_header .exit": "_exit"
    # "click": "toggleView"

  initialize: (@options) ->
    _.extend(@, @options)
    @$detail = @$('.full-mode')
    @model.bind("change:display", @changeDisplay, @)
    @$operator = @$(".card_item_header .operator")

  changeDisplay: () ->
    if @model.get("display")
      @openView()
    else
      @exitLayout()

  _open: () ->    
    @parentView.navigate("open/#{@model.id}/")

  _exit: () ->
    @parentView.navigate("")    

  toggleView: () =>
    @openView()

  openView: () ->
    @$operator.removeClass("open").addClass("exit").html("返回")
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
    @$(".card_item_row").hide()
    @$detail.show()
    @$el
      .css
        'margin-left': 0
        'opacity': 1
    $(window).trigger('resizeOrderChat')


  miniMode: () ->
    @$detail.hide()
    @$(".card_item_row").show()

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

  exitLayout: () -> 
    @$operator.removeClass("exit").addClass("open").html("打开")   
    @trigger("exitMenu")


root.TransactionTwoColumnsViewport = TransactionTwoColumnsViewport
