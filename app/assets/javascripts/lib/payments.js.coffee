# 支付 

root = (window || @)

class root.PayMentsView extends Backbone.View
  
  initialize: () ->
    @$el = $(@el)

  serialize: (data) ->
    names = @exclude_names()
    _.each names, (name) -> delete data[name]
    data

  exclude_names: () ->
    names = []
    _.each @tab_pane(), (elem) => 
      names.push($(elem).attr("id")) unless $(elem).hasClass("active")

    names

  tab_pane: () ->
    @$(".tab-content>.tab-pane")