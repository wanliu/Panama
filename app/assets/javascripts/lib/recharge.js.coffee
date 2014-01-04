# description: 充值

root = (window || @)

class root.RechargeView extends Backbone.View
  events: {
    "click .btn_paid" : "paid"
  }

  initialize: () ->
    @remote_url = @options.remote_url
    @$el = $(@el)
    @$input = @$("input:text[name='money']")

  paid: () ->
    data = @$el.serializeHash()
    names = @exclude_names()
    _.each names, (name) -> delete data[name]

    unless /^\d+(:?\.\d+)?$/.test data.money
      pnotify(text: "请填写正确的金额!", type: "warning")
      @$input.focus()
      return 
    
    $.ajax(
      url: @remote_url,
      data: data,
      success: () => console.log "aaaa"
    )

  exclude_names: () ->
    names = []
    _.each @tab_pane(), (elem) => 
      names.push($(elem).attr("id")) unless $(elem).hasClass("active")

    names

  tab_pane: () ->
    @$(".tab-content>.tab-pane")
