#帖子回复
#= require lib/hogan

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

  update: (callback) ->
    @fetch(
      url: "#{@urlRoot}/#{@id}",
      type: "PUT",
      data: {content: @get('content')}
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
  className: "row-fluid topic_comment"
  events: {
    "mouseover .content_panel" : "show_nav",
    "mouseout .content_panel" : "hide_nav",
    "click .comment_nav>.reply" : "reply",
    "click .comment_nav>.edit" : "show_edit",
    "click .comment_nav>.remove" : "remove",
    "click input:button.delete" : "remove",
    "click input:button.update" : "edit",
    "click input:button.cancel_edit" : "cancel_edit",
    "keyup textarea[name=content]" : "inspect_status"
  }
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @init_el()
    @$("abbr.timeago").timeago()

  init_el: () ->
    @user_el = $("<div class='span1' />")
    @comment_el = $("<div class='span11' />")
    @$el.append(@user_el).append(@comment_el)
    @user_el.append( @user_template() )

    @user_el.find(".user_avatar").append(@avatar_img())
    @render_panel()
    

    if @is_current_user()
      @comment_nav.append(@nav_edit_el()).append(@nav_remove_el())
    else
      @comment_nav.append(@nav_reply_el())

  is_current_user: () ->
    if @current_user?
      if @current_user.id.toString() is @model.get("user_id").toString()
        return true

    false

  render_panel: () ->
    @comment_el.html( @content_template() )
    @comment_content = @comment_el.find(".content")
    @render_content()

    @render_edit if @is_current_user()
    @comment_nav = @comment_el.find(".comment_nav")
    @comment_nav.append @create_time_el()

    @content_panel = @comment_el.find(".content_panel")
    @content_panel.find(".user_login").append(@user_login())

  render_edit: () ->
    @comment_el.find(".edit_panel").remove()
    @comment_el.append @edit_template()
    @edit_panel = @comment_el.find(".edit_panel")
    @textarea = @edit_panel.find("textarea")

  render_content: () ->
    @comment_content.html(
      Hogan.compile("{{{content_html}}}").render @model.toJSON()
    )

  render: () ->
    @$el

  show_nav: () ->
    @comment_nav.find(".nav_tag").show()

  hide_nav: () ->
    @comment_nav.find(".nav_tag").hide()

  reply: () ->
    $(@el).parents().find(".show_comment").hide()
    @trigger("set_reply_user", @model.get("user_login"))

  remove: () ->
    if confirm("是否确认删除评论？")
      @model.destroy success: (model, data) =>
        @trigger("remove_comment", @model)
        @$el.remove()

  edit: () ->
    content = @textarea.val().trim()
    return if content is ""
    @model.set("content", content)
    @model.update (model, data) =>
      @render_content()
      @cancel_edit()

  show_edit: () ->
    @render_edit()
    @edit_panel.show()
    @content_panel.hide()

  cancel_edit: () ->
    @edit_panel.hide()
    @content_panel.show()

  inspect_status: () ->
    content = @textarea.val().trim()
    button = @$("input:button.update")
    button.removeClass("disabled")
    button.addClass("disabled") if content is ""

  content_template: () ->
    "<div class='content_panel'>
      <div class='user_login'></div>
      <div class='comment_nav'></div>
      <div class='content'></div>
    </div>"

  user_template: () ->
    "<div class='user_avatar'></div>"

  avatar_img: () ->
    "<img src='#{@model.get("user_icon_url")}' class='img-rounded' />"

  user_login: () ->
    "<a href='javascript:void(0)'>#{@model.get("user_login")}</a>"

  create_time_el: () ->
    "<abbr class='timeago topic_date' title='#{@model.get("created_at")}'></abbr>"

  nav_reply_el: () ->
    "<a class='reply nav_tag' href='javascript:void(0)'>回复</a>"

  nav_edit_el: () ->
    "<a class='edit' href='javascript:void(0)'>编辑</a>"

  nav_remove_el: () ->
    "<a class='remove nav_tag' href='javascript:void(0)'>删除</a>"

  edit_template: () ->
    "<div class='edit_panel'>
      <div>
        <textarea name='content'>#{@model.get('content')}</textarea>
      </div>
      <div>
        <input type='button' value='保存更改' class='btn btn-primary btn-small update' />
        <input type='button' value='删除评论' class='btn btn-primary btn-small delete' />
        <input type='button' value='取消' class='btn btn-small cancel_edit' />
      </div>
    </div>"


class root.TopicCommentView extends Backbone.View
  notice_el: "<div class='notice'>暂时没有回复信息!</div>"
  events: {
    "click input.show_comment" : "show_comment"
    "click input:button.cancel" : "cancel_comment"
    "submit form.comment_form" : "create_comment"
    "click .more_comment" : "show_all_comment"
    "click .hide_more_comment" : "show_last_comment"
    "keyup textarea[name=content]" : "inspect_validate"
  }

  initialize: (options) ->
    _.extend(@, options)
    @load_init()
    @comments = new CommentList()
    @comments.bind("reset", @all_comment, @)
    @comments.bind("add", @add_comment, @)

    @topic_el = @$(".comments_panel")
    @more_comment_el = @$(".more_comment")
    @hide_more_comment_el = @$(".hide_more_comment")
    @textarea_el = @$("form.comment_form").find("textarea")
    @show_last_comment()

  load_init: () ->
    if @current_user?
      @$(".user_avatar").html("<img src='#{@current_user.icon_url}' class='img-polaroid' />")
      @$(".user_login").html(@current_user.login)

    @change_comment()

  all_comment: (collection) ->
    @topic_el.html("")
    collection.each (model) =>
      @add_comment(model)
    @inspect_notice()

  add_comment: (model) ->
    comment_view = new CommentView(
      current_user: @current_user,
      model: model )
    comment_view.bind("set_reply_user", _.bind(@set_reply_user, @))
    comment_view.bind("remove_comment", _.bind(@remove_comment, @))
    @topic_el.append(comment_view.render())
    @topic_el.find(".notice").remove()

  show_comment: () ->
    @$(".show_comment").hide()
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
    @$(".show_comment").show()

  create_comment: () ->
    data = {}
    _.each @$("form.comment_form").serializeArray(), (v) =>
      data[v.name] = v.value

    return false if not data.content? || data.content == ""
    @comment = new Comment(_.extend(data, {targeable_id: @topic.id}))
    @comment.topic (model, data) =>
      @textarea_el.val("")
      @comments.add data
      @change_comment()
    @$(".show_comment").show()
    @$(".comment_panel").hide()
    return false

  inspect_notice: () ->
    if @comments.length <= 0
      @topic_el.html(@notice_el)

  set_reply_user: (login) ->
    @textarea_el.val( "#{@textarea_el.val()} @#{login} " )
    @$(".comment_panel").show()

  remove_comment: (model) ->
    @comments.remove model
    @change_comment()
    @inspect_notice()

  inspect_validate: () ->
    content = @textarea_el.val().trim()
    button = @$("input:submit")
    button.removeClass("disabled")
    button.addClass("disabled") if content is ""

  change_comment: () ->
    @comment = new Comment()
    @comment.fetch_topic_count(@topic.id, (model, data) =>
      @more_comment_el.html("<span>#{data}<span>条评论  <i class='icon-chevron-down'></i>") if parseInt(data) > 2
    )