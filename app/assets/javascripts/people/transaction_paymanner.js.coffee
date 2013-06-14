#管理付款方式

class PayManner extends Backbone.View
  events: {
    "click .title" : "chose_manner"
  }

  initialize: (options) ->
    _.extend(@, options)

    @$radio = @$("input:radio")
    @name = @$('.name').text().trim()
    @code = @$(".code").text().trim()

  chose_manner: () ->
    @$radio[0].checked = true
    @set_name(name: @name, code: @code)


class TransactionPayManner extends Backbone.View
  events: {
    "click .mdify_show" : "toggleMdify",
    'click input:button.mdify' : "toggle_paymanner"
  }

  initialize: (options) ->
    @panel = @$(".paymanner_panel")
    @chose_panel = @$(".chose_paymanner_panel")
    @load_list()

  toggleMdify: () ->
    @panel.hide()
    @chose_panel.slideDown()

  toggle_paymanner: () ->
    @chose_panel.slideUp () =>
      @panel.show()

  load_list: () ->
    lis = @chose_panel.find("ul>li")
    _.each lis, (li) =>
      new PayManner(
        set_name: _.bind(@set_name, @),
        el: $(li))

  set_name: (pay_manner) ->
    @panel.find(".chose_name").html(pay_manner.name)


