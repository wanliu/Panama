#帖子回复
define ["jquery", "backbone"], ($, Backbone) ->

  class Comment extends Backbone.Model
    urlRoot: "/comments"
    topic: (callback) ->
      @fetch(
        url: "#{@urlRoot}/topic",
        data: {
          comment: {
            content: @get("content"),
            targeable_id: @get('targeable_id')
          }
        },
        type: "POST",
        success: callback
      )

    fetch_topic_count: (topic_id, callback) ->
      @fetch(
        url: "#{@urlRoot}/count",
        data: {targeable_type: "Topic", targeable_id: topic_id},
        success: callback
      )

  class CommentList extends Backbone.Collection
    model: Comment
    url: "/comments"

    fetch_topic: (data) ->
      @fetch(
        url: @url,
        data: _.extend(data, {targeable_type: "Topic"})
      )

  class CommentView extends Backbone.View
    className: "row-fluid comment"
    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)

      @user_el = $("<div class='span1' />")
      @comment_el = $("<div class='span11' />")

      @$el.append(@user_el)
      @$el.append(@comment_el)

      @user_el.append("<div class='user_avatar'></div>")
      @user_el.append("<div class='user_login'></div>")

      @user_el.find(".user_avatar")
      .append("<img src='#{@model.get("user_icon_url")}' class='img-polaroid' />")
      @user_el.find(".user_login").append(@model.get("user_login"))
      @comment_el.html(@model.get("content"))

    render: () ->
      @$el

  class TopicCommentView extends Backbone.View
    notice_el: "<div class='notice'>暂时没有回复信息!</div>"
    events: {
      "click button.show_comment" : "show_comment"
      "click input:button.cancel" : "cancel_comment"
      "submit form.comment_form" : "create_comment"
      "click .more_comment" : "show_all_comment"
      "click .hide_more_comment" : "show_last_comment"
    }

    initialize: (options) ->
      _.extend(@, options)
      @load_init()
      @comments = new CommentList()
      @comments.bind("reset", @all_comment, @)
      @comments.bind("add", @add_comment, @)

      @topic_el = @$(".comments")
      @more_comment_el = @$(".more_comment")
      @hide_more_comment_el = @$(".hide_more_comment")
      @show_last_comment()

    load_init: () ->
      if @current_user?
        @$(".user_avatar").html("<img src='#{@current_user.icon_url}' class='img-polaroid' />")
        @$(".user_login").html(@current_user.login)

      @comment = new Comment()
      @comment.fetch_topic_count(@topic.id, (model, data) =>
        @more_comment_el.html("#{data}条评论") if parseInt(data) > 2
      )

    all_comment: (collection) ->
      @topic_el.html("")
      collection.each (model) =>
        @add_comment(model)
      @inspect_notice()

    add_comment: (model) ->
      comment_view = new CommentView( model: model )
      @topic_el.append(comment_view.render())
      @topic_el.find(".notice").remove()

    show_comment: () ->
      @$(".comment_panel").toggle() if @current_user?

    show_last_comment: () ->
      @more_comment_el.show()
      @hide_more_comment_el.hide()
      @comments.fetch_topic(targeable_id: @topic.id, limit: 2)

    show_all_comment: () ->
      @more_comment_el.hide()
      @hide_more_comment_el.show()
      @comments.fetch_topic(targeable_id: @topic.id)

    cancel_comment: () ->
      @$(".comment_panel").hide()

    create_comment: () ->
      data = {}
      _.each @$("form.comment_form").serializeArray(), (v) =>
        data[v.name] = v.value

      if not data.content? || data.content == ""
        return false
      @comment = new Comment(_.extend(data, {targeable_id: @topic.id}))
      @comment.topic (model, data) =>
        @$("form.comment_form").find("textarea").val("")
        @comments.add data

      return false

    inspect_notice: () ->
      if @comments.length <= 0
        @topic_el.html(@notice_el)
