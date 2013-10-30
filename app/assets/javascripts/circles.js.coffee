#= require topic

root = window || @

class root.CircleListView extends Backbone.View

  initialize: (option) ->
    _.extend(@, option)

    @$left = @$(".left")
    @$right = @$(".right")

    @topics = new TopicViewList(
      sp_el: @el,
      add_topic: _.bind(@add_topic, @),
      fetch_url: "/communities/#{@circle_id}/topics")

    @view = new CreateTopicView(
      circle_id: @circle_id,
      create_topic: _.bind(@create_topic, @),
      el: @$(".left>.toolbar"))

  add_topic: (template) ->
    @short_elem().append(template)

  create_topic: (template) ->
    @short_elem().prepend(template)

  short_elem: () ->
    ltopic = $(".topics", @$left)
    rtopic = $(".topics", @$right)
    if ltopic.height() > rtopic.height() then rtopic else ltopic





