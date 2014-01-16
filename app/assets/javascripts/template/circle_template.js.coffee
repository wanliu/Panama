
root = (window || @)

class root.CircleViewTemplate extends Backbone.View
  className: "circle info-wrapper"

  initialize: () ->
    @$el = $(@el)
    @template = Handlebars.compile($("#circle_template").html())
    @$el.attr("data-value-id", @model.id)
    @$el.html(@template(@model)) if @template

  render: () ->
    @

class root.CirclePreview extends Backbone.View
  events: {
    "click .column>.circle .add_circle" : "join"
  }

  initialize: (options) ->    
    _.extend(@, options)
    @$el = $(@el)

    @view = new ApplyJoinCircle({      
      current_user_login: @login
    })

  join: (event) ->  
    @view.el = $(event.currentTarget)
    @view.model = {id: @view.el.attr("data-value-id")}
    @view.apply_join_circle()

  render: () ->
    @ 
