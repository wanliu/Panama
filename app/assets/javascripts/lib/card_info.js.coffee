root = window || @


class CardInfo extends Backbone.View
  events: {
    # "mouseenter" : "show"
    # "mouseleave" : "hide"
    "mouseenter" : "showActions"
    "mouseleave" : "hideActions"
  }

  initialize: () ->
    @$detail = @$(".info_detail")
    @$actions = @$(".actions")

  show: (e) ->
    $(".info-wrapper .info_detail").each () -> $(@).hide();     
    $top = e.pageY - $(document).scrollTop();
    $left = e.pageX - $(document).scrollLeft();
    @$detail.css({
      'left': $left,
      'top': $top})

    @$detail.show()


  hide: () ->
    @$detail.hide()

  showActions: (e) ->
    @$actions.animate({
      top : 60,
      opacity: 1
    })

  hideActions: (e) ->
    @$actions.animate({
      top:  120,
      opacity: 0
    })

  render: () ->
    @$el

class root.UserCardInfo extends CardInfo

class root.ShopCardInfo extends CardInfo

