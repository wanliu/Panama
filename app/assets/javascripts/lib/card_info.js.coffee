root = window || @

class root.UserCardInfo extends Backbone.View
  events: {
    "mouseenter" : "show"
    "mouseleave" : "hide"
  }

  initialize: () ->
    @$detail = @$(".info_detail")

  show: (e) ->
    $(".info-wrapper .info_detail").each () -> $(@).hide();     
    $top = e.pageY - $(document).scrollTop();
    $left = e.pageX - $(document).scrollLeft();
    @$detail.css({
      'left': $left + 10,
      'top': $top - 10});
    @$detail.show();

  hide: () ->
    @$detail.hide();

  render: () ->
    @$el

class root.ShopCardInfo extends Backbone.View
  events: {
    "mouseenter" : "show"
    "mouseleave" : "hide"
  }

  initialize: () ->
    @$detail = @$(".info_detail")

  show: (e) ->
    $(".info-wrapper .info_detail").each () -> $(@).hide();     
    $top = e.pageY - $(document).scrollTop();
    $left = e.pageX - $(document).scrollLeft();
    @$detail.css({
      'left': $left + 10,
      'top': $top - 10});
    @$detail.show();

  hide: () ->
    @$detail.hide()

  render: () ->
    @$el
