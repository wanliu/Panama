
root = (window || @)

class root.TransactionComplete extends Backbone.View
  
  initialize: () ->
    @views = []

  register: (view) ->
    @views.push view

  start: () ->
    that = @
    _.each @views, (view) ->
      view.open_on () ->
        @show()
        that.vanish(@)

      view.home_on () ->  
        that.expend()

    if Backbone.History.started
      Backbone.history.stop()
      Backbone.history.start()

  vanish: (view) ->
    _.each @views, (v) ->
      v.hide() unless v == view

  expend: () ->
    _.each @views, (view) -> view.show()
