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
    else
      @loadTemplate()

class TransactionThreeViewport extends Backbone.View

  el: ".transaction-list"
  child: ".order_item"
  contrainer: ".threeD-viewport"

  initialize: () ->
    @rows = []
    @in3D = false
    @$contrainer = @$(@contrainer)
    @loadView()

  getCurrentTransaction: () ->

  loadView: () ->
    @$(@child).each (i, ele) =>
      rowView = new MiniRow3DView(el: ele, parentView: @) 
      @rows.push(rowView)

  activeRowView: (view) =>
    @exceptView(view)
    @enabled3D () =>
      index = @rows.indexOf(@except)

      for rowView, i in @rows
        el = rowView.$el[0]
        unless rowView == @except
          if i < index
            @fast3UpElement(el, index - i)
          else if i > index
            @fast3DownElement(el, i - index)

      view.active()


  exceptView: (view) ->
    @except = view

  disable3D: (callback) =>
    if @in3D
      @in3D = false 

      @$contrainer.removeClass('threeD')

      for rowView in @rows
          rowView.normal() unless rowView == @except

    callback()

  enabled3D: (callback) =>
    unless @in3D
      @in3D = true
     
      @$contrainer.addClass('threeD')


      for rowView, i in @rows
        rowView.fastThreeD() unless rowView == @except

    callback()

  t3UpView: (view, index) =>
    # base = -200
    # base -= index * 40
    view.threeD()
    base = -view.height - index * 40
    # @disableAnimate(view)
    view.$el.css({top: 0})
    # view.$el.hide()
    @enableAnimate(view)
    view.$el.css({ 
      "transform-origin": "0px 100%",
      "-webkit-transform": "translate3d(0px, #{base}px, -100px) rotateX(65deg)",
      "-moz-transform": "translate3d(0px, #{base}px, -100px) rotateX(65deg)",
      "transform": "translate3d(0px, #{base}px, -100px) rotateX(65deg)"
    })
      # .delay(500)
      # .show()

  t3DownView: (view, index) =>
    view.threeD()
    base = 400 + index * 40
    @disableAnimate(view)
    view.$el.css({top: 0})
    # view.$el.hide()
    @enableAnimate(view)
    view.$el.css({ 
      "transform-origin": "0px 0px",
      "-webkit-transform": "translate3d(0px, #{base}px, -100px) rotateX(-45deg)",
      "-moz-transform": "translate3d(0px, #{base}px, -100px) rotateX(-45deg)",
      "transform": "translate3d(0px, #{base}px, -100px) rotateX(-45deg)"
    })
      # .delay(500)
      # .show()

  fast3UpElement: (element, index) =>
    # height = parseInt(element.style.height)
    base = -element.clientHeight - index * 40
    element.style.transition = "none"
    element.style.top = 0
    element.style.transition = "0.3s"    
    # view.$el.css({top: 0})
    # view.$el.hide()
    # @enableAnimate(view)
    element.style.transformOrigin = "0px 100%"
    element.style.webkitTransform = "translate3d(0px, #{base}px, -100px) rotateX(65deg)"
    element.style.mozTransform = "translate3d(0px, #{base}px, -100px) rotateX(65deg)"
    element.style.msTransform = "translate3d(0px, #{base}px, -100px) rotateX(65deg)"
    element.style.transform = "translate3d(0px, #{base}px, -100px) rotateX(65deg)"
    # "-moz-transform": "translate3d(0px, #{base}px, -100px) rotateX(65deg)",
    # "transform": "translate3d(0px, #{base}px, -100px) rotateX(65deg)"

  fast3DownElement: (element, index) =>
    base = 400 + index * 40
    element.style.transition = "none"
    element.style.top = 0
    element.style.transition = "0.3s"    

    element.style.transformOrigin = "0px 0px"
    element.style.webkitTransform = "translate3d(0px, #{base}px, -100px) rotateX(-45deg)"
    element.style.mozTransform = "translate3d(0px, #{base}px, -100px) rotateX(-45deg)"
    element.style.msTransform = "translate3d(0px, #{base}px, -100px) rotateX(-45deg)"
    element.style.transform = "translate3d(0px, #{base}px, -100px) rotateX(-45deg)"

    # "transform-origin": "0px 0px",
    # "-webkit-transform": "translate3d(0px, #{base}px, -100px) rotateX(-45deg)",
    # "-moz-transform": "translate3d(0px, #{base}px, -100px) rotateX(-45deg)",
    # "transform": "translate3d(0px, #{base}px, -100px) rotateX(-45deg)"

  disableAnimate: (view) ->
    view.$el.css({
      "-webkit-transition": "none",
      "-moz-transition": "none",
      "-ms-transition": "none",
      "transition": "none"
    })

  enableAnimate: (view) ->
    view.$el.css({
      "-webkit-transition": "0.3s",
      "-moz-transition": "0.3s",
      "-ms-transition": "0.3s",
      "transition": "0.3s"
    })

  fastDisableAnimate: (el) ->
    el.style.webkitTransition = "none"
    el.style.mozTransition = "none"
    el.style.msTransition = "none"
    el.style.transition = "none"
    
  fastEnableAnimate: (el) ->
    el.style.webkitTransition = "0.3s"
    el.style.mozTransition = "0.3s"
    el.style.msTransition = "0.3s"
    el.style.transition = "0.3s"

# class Css3Effect

#   prefixes: [
#     "-webkit",
#     "-moz",
#     "-ms",
#     ""
#   ]

#   constructor: (@element, @options) ->





class MiniRow3DView  extends Backbone.View

  events:
    "click .btn.open": "openView"
    "click": "toggleView"

  initialize: (@options) ->
    _.extend(@, @options)

  toggleView: () =>
    @openView()

  openView: () ->
    @activeRow3DView()

  activeRow3DView: () ->
    if @parentView?
      @parentView.activeRowView(@)

  saveSize: () =>
    @width = @$el.width()
    @height = @$el.height()

  restoreSize: () =>

  active: () =>
    @threeD()
    @$el
      # .removeClass('threeD')
      .addClass("active")
      .css({
        "-webkit-transform": "translate3d(0px, 0px, 0px) rotateX(0deg)",
        "-moz-transform": "translate3d(0px,0px, 0px) rotateX(0deg)",
        "transform": "translate3d(0px, 0px, 0px) rotateX(0deg)"         
        })

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
      .css({
        height: @height,
        position: 'absolute',
      })
      .removeClass("active")

  fastThreeD: () =>
    @saveSize()
    @$el
      .addClass("threeD")
      .removeClass("active")

    el = @$el.get(0)
    el.style.height = @height
    el.style.position = 'absolute'

  fastNormal: () =>
    @$el.removeClass('threeD')
    el = @$el.get(0)
    el.style.webkitTransform = "translate3d(0px, 0px, 0px) rotateX(0deg)"
    el.style.mozTransform = "translate3d(0px,0px, 0px) rotateX(0deg)"
    el.style.transform = "translate3d(0px,0px, 0px) rotateX(0deg)"

  fastActive: () =>
    @fastThreeD()

    @$el
      .addClass("active")

    el = @$el.get(0)
    el.style.webkitTransform = "translate3d(0px, 0px, 0px) rotateX(0deg)"
    el.style.mozTransform = "translate3d(0px,0px, 0px) rotateX(0deg)"
    el.style.transform = "translate3d(0px,0px, 0px) rotateX(0deg)"    

root.TransactionThreeViewport = TransactionThreeViewport