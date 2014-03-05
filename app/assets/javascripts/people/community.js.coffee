
root = window || @

class Circle extends Backbone.Model

class CircleList extends Backbone.Collection
  model: Circle
  set_url: (url) ->
    @url = url

class CircleView extends Backbone.View
  className: "circle"

  events: 
    "click .icon-cog" : "setting_load"

  initialize: () ->
    _.extend(@, @options)
    @$el = $(@el)

  setting_load: (e) ->
    id = $(e.currentTarget).parents("a").attr("data-value-id")
    $.ajax(
      url: "/people/#{@login}/circles/#{ id }",
      success: (html) ->
        $('#mySetting .modal-body').html(html)
        $("#mySetting").modal()
    )

  render: () ->
    data = @model.toJSON()
    template = Handlebars.compile($("#you-template-circle").html())
    @$el.html(template(data))

class MyCircleView extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    @circles = new CircleList()
    @circles.set_url(@url)
    @circles.bind("add", _.bind(@add, @))
    @circles.bind("reset", _.bind(@reset, @))
    @circles.fetch()

  add: (model) ->
    view = new CircleView(model: model,login: @login)
    @el.append(view.render())

  reset: (collections) ->
    return @el.html('没有商圈，创建属于你自己的商圈吧。') if collections.length is 0
    collections.each (model) =>
      @add(model)

class root.CommunityView extends Backbone.View

  initialize: () ->
    _.extend(@, @options)

  render: () ->

  fetch_circles: (url) ->
    new MyCircleView({
      url: url,
      el: @$(".circles"),
      login: @login})

class root.CommunitySearch extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    # @template = Handlebars.compile($("#search-template-circle").html())

  events:
    "keyup .search_circles" : "search_circles" 

  search_circles: (e) ->
    if e.keyCode == 13
      $.ajax({
        url: "/search/circles",
        data: {q: {query: @$(".search_circles").val()} },
        success: (models) =>
          @render(models)
      })

  render: (models) ->
    @$(".circles").html("")
    _.each models, (model) =>
      # @$(".circles").append(@template(model))
      view = new CircleView(model: new Circle(model), login: @login)
      @$(".circles").append(view.render())
      new ApplyJoinCircle({
        el: view.el.find(".add_circle"),
        model: {id: model.id},
        current_user_login: @login,
      })


