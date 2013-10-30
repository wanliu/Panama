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
        view = new TopicView(data: data)
        @create_topic(view.render())
    )
    false

  form_serialize: () ->
    forms = @$form.serializeArray()
    data = {}
    $.each forms, (i, v) ->
      data[v.name] = v.value
    data

class LoadTopicList extends InfiniteScrollView
  msg_el: "#load_message_notifiy"

  initialize: (options) ->
    @fetch_url = options.fetch_url
    @add_one = options.add_one
    super options

class TopicViewList extends Backbone.View

  initialize: (options) ->
    @add_topic = options.add_topic
    @sp_el = options.sp_el

    new LoadTopicList(
      sp_el: @sp_el,
      add_one: _.bind(@add_one, @),
      fetch_url: options.fetch_url)

  add_one: (data) ->
    view = new TopicView(data: data)
    @add_topic(view.render())

class TopicView extends Backbone.View
  className: "row-fluid topic-panel"
  events: {
    "click .send_comment" : "show_commnet"
    "click .comment_form .cancel" : "hide_comment"
    "submit form.comment_form" : "comment"
  }
  initialize: (options) ->
    @model = new Topic(options.data)
    @load_template()
    @$el = $(@el)

  render: () ->
    @$el.html(@template.render(@model.toJSON()))
    @$("abbr.timeago").timeago()
    @$el

  load_template: () ->
    template = $("#create-topic-template").html()
    @template = Hogan.compile(template)

  show_commnet: () ->
    @$(".send_comment").hide()
    @$(".comment_panel").show()

  hide_comment: () ->
    @$(".send_comment").show()
    @$(".comment_panel").hide()

  comment: () ->

    return false

root.CreateTopicView = CreateTopicView
root.TopicViewList = TopicViewList
