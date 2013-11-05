#= require panama
#= require ajaxify
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require backbone
#= require following
#= require topic

root = window || @

class CircleCategory extends Backbone.View

	initialize: () ->
		_.extend(@, @options)

	events:
		"click .add_category" : "edit"
		"blur .new_category" : "submit"

	edit: () ->
		@$(".add_category").hide()
		input = $("<input type='text' placeholder='新类别' class='new_category span11'/>").insertBefore(".add_category")
		input.focus()

	submit: () ->
		$category_name = $(".new_category").val()
		@$(".new_category").remove()
		@$(".add_category").show()
		if $category_name != ""
			$.ajax({
				type: "post",
				dataType: "json",
				data: { name: $category_name },
				url: "/communities/#{ @circle_id }/circles/add_category",
				success: (data) =>
          @$(".community_category").append("<li>
            <a data-value-id='#{ data.id}' href='/communities/#{ @circle_id }/categories/#{data.id}' class='circle-category-#{data.id}'>#{ data.name} </a>
            </li>")
			})


class CircleListView extends Backbone.View
  events:
    "click .following .join" : "join_circle"

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
    if @$left.height() > @$right.height() then rtopic else ltopic

  join_circle: () ->
    $.ajax(
      url: "/communities/#{@circle_id}/circles/join"
      type: "POST",
      success: () =>
        window.location.href = "/communities/#{@circle_id}/circles"
    )


root.CircleCategory = CircleCategory
root.CircleListView = CircleListView
