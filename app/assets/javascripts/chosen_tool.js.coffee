root = window || @
class root.chosenTool extends Backbone.View
  
  events: 
   "click .circle" : "select_circle"

  initialize: (options) ->
    _.extend(@, options)
    @el = $(@el)

  state: () ->
    if @$(".selected").length > 0
      @$(".shared").removeClass("disabled")
    else
      @$(".shared").addClass("disabled")

  select_circle: (e) ->
    target = $(e.currentTarget)
    if target.hasClass("selected")
      target.removeClass("selected")
    else
      target.addClass("selected")
    @state()

  data: () ->
    ids = []
    if @$(".selected").length > 0
      els = @$(".selected") 
      _.each els, (el) =>
        ids.push($(el).attr("data-value-id"))
      return ids
    else
      return false