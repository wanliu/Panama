#= require topic

root = window || @

class root.CircleListView extends Backbone.View

  initialize: (option) ->
    _.extend(@, option)

    @$left = @$(".left")
    @$right = @$(".right")

    @topic = new TopicViewList(
      add_topic: _.bind(@add_topic, @),
      fetch_url: "/communities/#{@circle_id}/topics")

    @view = new CreateTopicView(
      circle_id: @circle_id,
      create_topic: _.bind(@create_topic, @),
      el: @$(".left>.toolbar"))

    @load_template()

  add_topic: (data) ->
    @short_elem().append(@template.render(data))
    $("abbr.timeago").timeago();

  create_topic: (data) ->
    @short_elem().prepend(@template.render(data))
    $("abbr.timeago").timeago();

  short_elem: () ->
    ltopic = $(".topics", @$left)
    rtopic = $(".topics", @$right)
    if ltopic.height() > rtopic.height() then rtopic else ltopic

  load_template: () ->
    template = $("#create-topic-template").remove().html()
    @template = Hogan.compile(template)





