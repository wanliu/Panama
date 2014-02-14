#= require 'lib/card_info'
root = (window || @)

class root.UserViewTemplate extends Backbone.View
  className: "user info-wrapper"

  initialize: () ->
    @$el = $(@el)
    @$el.attr("user-id", @model.id)
    @template = $(Handlebars.compile($("#user_template").html())(@model))
    @$el.html(@template)   

    new UserCardInfo(
      el: @template,
      model: @model
    )

  render: () ->    
    @
