#= require topic
#= require lib/circle_info

root = window || @

class root.CircleListView extends Backbone.View
  events:
    'click .following .join': 'join_circle'
    'click .quit_circle'    : 'quit_circle'

  initialize: (option) ->
    _.extend(@, option)

    # @$left = @$(".left")
    # @$right = @$(".right")

    # @topics = new TopicViewList(
    #   sp_el: @el,
    #   add_topic: _.bind(@add_topic, @),
    #   fetch_url: @topic_fetch_url)

    # @view = new CreateTopicView(
    #   circle_id: @circle_id,
    #   create_topic: _.bind(@create_topic, @),
    #   el: @$(".left>.toolbar"))

    # new CircleInfoView(
    #   el: @$(".circle-description"),
    #   circle_id: @circle_id
    # )

  # add_topic: (template) ->
  #   @short_elem().append(template)

  # create_topic: (template) ->
  #   @short_elem().prepend(template)

  # short_elem: () ->
  #   ltopic = $(".topics", @$left)
  #   rtopic = $(".topics", @$right)
  #   if @$left.height() > @$right.height() then rtopic else ltopic

  # join_circle: () ->
  #   $.ajax(
  #     url: "/communities/#{@circle_id}/circles/join"
  #     type: "POST",
  #     success: () =>
  #       window.location.href = "/communities/#{@circle_id}/circles"
  #   )

  quit_circle: (event) ->
    return unless confirm('确定退出商圈吗？')
    $.ajax({
      type: "delete",
      url: "/communities/#{@circle_id}/circles/quit_circle",
      success: (data, xhr, res) =>
        window.location.href = "/communities/#{@circle_id}/circles"
    })

