#

root = (window || @)

class root.WithDrawMoneyView extends Backbone.View
  expand_class: "_collapse"

  events: {
    "click .bank-wrapper input:radio" : "check",
    "click .expand" : "expand"
  }

  initialize: () ->
    @$bank_wrap = @$(".bank-wrapper")

  check: (event) ->
    bank_id = $(event.currentTarget).val()
    $(".bank", @$bank_wrap).removeClass("active")
    $(".bank_#{bank_id}", @$bank_wrap).addClass("active")
    @$bank_wrap.addClass(@expand_class)

    active = $(".bank.active", @$bank_wrap)
    height = active.height()
    width =_.max(_.map $(".bank", @$bank_wrap), (elem) -> $(elem).width())

    _.reduce $(".bank:not(.active)", @$bank_wrap), (mem, elem) =>
      $(elem).css(
        height: height,
        width: width,
        left: mem * 3
        zIndex: mem
        top: mem * 3)
      mem += 1      
    , 1

    active.css(
      height: height,
      width: width,
      left: 0,
      zIndex: 90,
      top: 0
    )

  expand: () ->
    @$bank_wrap.removeClass(@expand_class)

