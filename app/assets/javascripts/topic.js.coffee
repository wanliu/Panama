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

class Comments extends Backbone.Collection
  seturl: (url) ->
    @url = url

class CreateTopicView extends Backbone.View
  events:
    "submit form.create_topic"    : "create",
    "keyup textarea[name=content]": "textarea_status"
    "click .add-attachments"      : "toggleAttachments"

  initialize: (options) ->
    _.extend(@, options)

    @$el = $(@el)
    @$form = @$("form.create_topic")
    @$content = @$("textarea[name=content]")
    @$button = @$("input:submit")

  toggleAttachments: () ->
    @$(".attachments-panel").slideToggle()

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
        view = new TopicView(data: data)
        @create_topic(view.render())
        @$content.val('')
        @$(".attachments-panel").hide()
        @$(".attachable:first").remove()
      error: (data) =>
        try
          err = JSON.parse(data.responseText)
          pnotify({title: "出错了！", type: "error", text: err.join("<br />")})
        catch err
          pnotify({title: "出错了！", type: "error", text: data.responseText})
    )
    false

  form_serialize: () ->
    forms = @$form.serializeArray()
    data = {}
    $.each forms, (i, v) ->
      data[v.name] = v.value
    data

class LoadTopicList extends InfiniteScrollView
  # msg_el: "#load_message_notifiy"

  initialize: (options) ->
    @fetch_url = options.fetch_url
    @add_one = options.add_one
    super options
    @fetch()

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


class CommentView extends Backbone.View
  className: "comment"

  initialize: () ->
    @$el = $(@el)
    @model.bind("show", @show, @)
    @model.bind("hide", @hide, @)

  render: () ->
    @template = Hogan.compile $("#create-comment-template").html()
    @$el.html(@template.render(@model.toJSON()))
    @$("abbr.timeago").timeago()
    @$el

  show: () ->
    @$el.slideDown()

  hide: () ->
    @$el.slideUp()

  display: () ->
    @$el.show()

class TopicView extends Backbone.View
  className: "row-fluid topic-panel"

  events:
    "click .send_comment"         : "show_create_commnet"
    "click .comment_form .cancel" : "hide_create_comment"
    "submit form.comment_form"    : "comment"
    "keyup .comment_form textarea": "textarea_status"
    "click .more_comment"         : 'more_comment'
    "click .hide_comment"         : 'hide_comment'
    'click .add_participate'      : 'create_participate'

  initialize: (options) ->
    @model = new Topic(options.data)
    @model.bind("change:comments_count", @change_count, @)

    @comments = new Comments()
    @comments.bind("add", @add_comment, @)

    @load_template()
    @$el = $(@el)

  render: () ->
    @$el.html(@template.render(@model.toJSON()))
    @$("abbr.timeago").timeago()
    @$textarea = @$(".comment_form textarea")
    @$btn_comment = @$(".comment_form input:submit")
    @$display_comment = @$(".display-comment")
    @comment_init()
    @load_participates()
    @$el

  add_comment: (model) ->
    method = model.get("display_way") || 'show'
    view = new CommentView(model: model)
    @$(".comments_panel").append(view.render())
    view[method]()

  load_template: () ->
    template = $("#create-topic-template").html()
    @template = Hogan.compile(template)

  show_create_commnet: () ->
    @$(".send_comment").hide()
    @$(".comment_panel").show()
    @$textarea.focus()

  hide_create_comment: () ->
    @$(".send_comment").show()
    @$(".comment_panel").hide()

  comment: () ->
    return false if @$btn_comment.hasClass("disabled")
    $.ajax(
      url: "#{@root_url()}/create_comment",
      type: 'POST',
      data: {comment: { content: @$textarea.val() }},
      success: (data) =>
        @$textarea.val('')
        @inc_comment_count()
        @comments.add(data)
    )
    return false

  comment_init: () ->
    @display_comment_bar()
    @init_data(@model.get("top_comments"), 'display')

  init_data: (data, display_way = 'show') ->
    @$(".comments_panel").html('')
    @comments.reset()
    _.each data, (d) => @comments.add(_.extend({
      display_way: display_way}, d))

  change_count: () ->
    @$(".display-comment.more_comment>.describe").html("#{@model.get('comments_count')}评论")

  display_comment_bar: () ->
    if @model.get('comments_count') > 3
      $(".describe", @$display_comment).html("#{@model.get('comments_count')}评论")
      @$display_comment.addClass("more_comment")

  root_url: () ->
    "/communities/#{@model.get('circle_id')}/topics/#{@model.id}"

  inc_comment_count: () ->
    count = @model.get("comments_count")
    @model.set(comments_count: ++count)

  more_comment: () ->
    count = @comments.length
    if count > 0 and count is @model.get("comments_count")
      @change_comments(i, "show") for i in [0..count-1]
      @change_display("top")
    else
      $.ajax(
        url: "#{@root_url()}/comments"
        success: (data) =>
          @model.set(comments_count: data.length)
          @change_display("top")
          @init_data(data)
      )

  hide_comment: () ->
    count = @comments.length
    if count > 3
      @change_comments(i, "hide") for i in [0..count-4]
      @change_display("down")

  change_display: (state) ->
    describe = $(".describe", @$display_comment)
    icon = $("i", @$display_comment)

    if state == "top"
      @$display_comment.removeClass("more_comment").addClass("hide_comment")
      describe.html("隐藏评论")
      icon.addClass("icon-chevron-top").removeClass("icon-chevron-down")
    else
      @$display_comment.removeClass("hide_comment").addClass("more_comment")
      describe.html("#{@model.get('comments_count')}评论")
      icon.addClass("icon-chevron-down").removeClass("icon-chevron-top")

  textarea_status: () ->
    value = @$textarea.val().trim()
    if _.isEmpty(value)
      @$btn_comment.addClass("disabled")
    else
      @$btn_comment.removeClass("disabled")

  change_comments: (i, call_name) ->
    @comments.models[i].trigger(call_name)

  load_participates: () ->
    $.ajax(
      url: "#{@root_url()}/participates",
      success: (data) =>
        _.each data, (d) =>
          @$(".participates").append(@render_participate(d))
    )

  create_participate: () ->
    $.ajax(
      url: "#{@root_url()}/participate",
      type: 'POST',
      success: (data) =>
        el = @$(".participates .count")
        count = if _.isEmpty(el.text().trim()) then 0 else parseInt(el.text())
        el.html(++count)
        $(@render_participate(data)).insertAfter(@$(".participates>.add_participate"))
    )

  render_participate: (data) ->
    "<a data-toggle='tooltip' data-placement='top' data-original-title='#{data.login}' href='javascript:void(0)' class='participate'>
      <img src='#{data.photos.avatar}' />
    </a>"

root.CreateTopicView = CreateTopicView
root.TopicViewList = TopicViewList
