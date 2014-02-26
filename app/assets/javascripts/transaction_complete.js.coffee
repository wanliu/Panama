
root = (window || @)

class root.TransactionComplete extends Backbone.View
  
  initialize: () ->
    @current_view = null
    @views = []

  register: (view) ->
    @views.push view
    @bindEvent view 

  bindEvent: (view) ->
    that = @    
    view.open_on () ->
      @show()
      that.vanish(@)

    view.home_on () -> that.expend()
    old_register = view.register 
    view.register = () ->
      that.vanish(@)
      old_register.apply(@, arguments)

  vanish: (view) ->
    @current_view = view
    _.each @views, (v)  => @view_hide(v)
      
  view_hide: (view) ->
    view.hide() if view isnt @current_view

  expend: () ->
    _.each @views, (view) -> view.show()
