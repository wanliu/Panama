root = @ || window

class MiniLeftSideView extends Backbone.View

  wrap: ".wrap"
  menuDocker: ".logo"

  initialize: (@options) ->
    _.extend(@, @options)
    @$wrap = $(@wrap)
    @$menuDocker = $(@menuDocker)
    @mininum = false

  buildMenu: () ->
    @$menu = $(">.menu", @$menuDocker)
    if @$menu.length <= 0
      @$menu = $("<a href='javascript:void(0)' class='menu' ><i class='icon-reorder' /></a>").prependTo(@$menuDocker)
      @$menu
        .css({
          'width': 40,
          'height': 40,
          'font-size': 30,
          'float': 'left'
        })
        .click(@toggleSide)
      @addExitButton()   

  addExitButton: () ->
    menus = @$(".side-nav")

    exitButton = $("""
       <li class="return-layout">
          <a href="/" class="side-fiery">
            <i class="icon-reply"></i>
            <span class="name">返回</span>
          </a>
        </li>""")

    btn = exitButton.find('a')
    btn.click () =>
      @exitWrap()
      false
    # id = menus.attr(id)
    menus
      .append(exitButton)

  removeExitButton: () ->
    menus = @$(".side-nav")
    li =  menus.find("li.return-layout")
    li.remove()
    if (@exitCallback && _.isFunction(@exitCallback))
      @exitCallback()

  exitWrap: () ->
    @restore()
    @removeExitButton()

  toggleSide: () =>
    if @mininum
      @show(true)
    else
      @hide()

    false

  hide: () ->
    @mininum = true

    @$el
      .css({
        'transition': "0.3s",
        'overflow': 'hidden',
        'margin-left': -@sideWidth
      })
      # .width(0)

  show: (change = false) ->
    @mininum = false

    attrs = {
      'overflow': 'visible',
      'margin-left': 0
    }

    if change
      attrs = _.extend(attrs, {
        'background-color': 'white',
        'color': '#555'
      })

    @$el
      .css(attrs)
      # .width(@sideWidth)
      # .height(@sideHeight)

  mini: () ->
    # unless @mininum
    @$contrainer = @$el.wrap("<div>")

    @wrapLeft = @$wrap.css('margin-left')
    @sideWidth = @$el.width()
    @sideHeight = @$el.height()

    @hide()

    @$wrap
      .css({
        'margin-left': 0
      })

    @$menu.fadeIn()

  restore: () ->
    # if @mininum
    @$wrap.css('margin-left', @wrapLeft)

    @show()

    @$el.attr('style', '')

    @$wrap
      .css({
        'margin-left': @wrapLeft
      })      

    @$menu.fadeOut()
    # @$contrainer
    @$el.unwrap()


root.MiniLeftSideView = MiniLeftSideView