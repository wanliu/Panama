#describe: 社交帖子
#= require lib/timeago
#= require topic_comment
#= require lib/infinite_scroll

root = window || @

class Topic extends Backbone.Model
  seturl: (url) ->
    @urlRoot = url

class TopicList extends Backbone.Collection
  model: Topic
  seturl: (url) ->
    @url = url

class CreateTopicView extends Backbone.View

  events: {
    "submit form.create_topic": "create",
    "keyup textarea[name=content]": "textarea_status"
  }

  initialize: (options) ->
    _.extend(@, options)

    @$el = $(@el)
    @$form = @$("form.create_topic")
    @$content = @$("textarea[name=content]")
    @$button = @$("input:submit")

  textarea_status: () ->
    content = @$content.val().trim()
    if content is ""
      @$button.addClass("disabled")
    else
      @$button.removeClass("disabled")

  create: () ->
    data = @form_serialize()
    return false if data.content is ""
    $.ajax(
      type: "POST",
      url: "/communities/#{@circle_id}/topics",
      data: {topic: data},
      success: (data) =>
        @$content.val('')
        @create_topic(data)
    )
    false

  form_serialize: () ->
    forms = @$form.serializeArray()
    data = {}
    $.each forms, (i, v) ->
      data[v.name] = v.value
    data

class LoadTopicList extends InfiniteScrollView
  initialize: (options) ->
    @fetch_url = options.fetch_url
    @add_one = options.add_one
    super options

class TopicViewList extends Backbone.View

  initialize: (options) ->
    _.extend(@, options)
    new LoadTopicList(
      add_one: _.bind(@add_one, @),
      fetch_url: @fetch_url)

  add_one: (data) ->
    @add_topic(data)



root.CreateTopicView = CreateTopicView
root.TopicViewList = TopicViewList