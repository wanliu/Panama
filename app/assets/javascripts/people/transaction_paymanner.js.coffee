#管理付款方式

root = window || @

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
    @set_name({name: @name, code: @code}, @$(".guide"))


class root.TransactionPayManner extends Backbone.View
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

  toggle_guide: (guide) ->
    if guide.css("display") == "none"
      guides = @chose_panel.find("ul>li>.guide")
      guides.slideUp()
      guide.slideDown()



  load_list: () ->
    lis = @chose_panel.find("ul>li")
    _.each lis, (li) =>
      new PayManner(
        set_name: _.bind(@set_name, @),
        el: $(li))

  set_name: (pay_manner, guide) ->
    @panel.find(".chose_name").html(pay_manner.name)
    @toggle_guide(guide)

