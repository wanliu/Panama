#describe: 社交帖子
#= require lib/timeago
#= require topic_comment
#= require twitter/bootstrap/tooltip
#= require twitter/bootstrap/popover


root = window || @

class Topic extends Backbone.Model
  seturl: (url) ->
    @urlRoot = url
  receives: (callback) ->
    @fetch({
      url: "#{@urlRoot}/receives/#{@id}",
      success: callback
    })

class TopicList extends Backbone.Collection
  model: Topic
  seturl: (url) ->
    @url = url

class TopicView extends Backbone.View
  avatar_img: $("<img class='img-circle user-avatar' />")

  events: {
    "click .external" : "external_receive",
    "click .circle" : "circle_receive",
    "click .puliceity" : "puliceity_receive",
    "click .close-label" : "hide_receive"
  }

  initialize: (options) ->
    _.extend(@, options)

    @$el = $(@el)
    @$el.html(@template.render(@model.toJSON()))
    @show_attachments()

    new TopicCommentView(
      el: @$(".topic-comments"),
      topic: @model,
      current_user: @current_user
    )

    @$(".user-info img.avatar").attr("src", @model.get("avatar_url"))
    @$("abbr.timeago").timeago()
    @$(".send_user").html(@find_owner())

    @puliceity_hide_status()
    @switch_style()

  render: () ->
    @$el

  switch_style: () ->
    if @model.get("owner_type") == "Shop"
      @$(".user_panel").html("由 #{@model.get("send_login")}发布")

  puliceity_hide_status: () ->
    if @model.get("status") is "community"
      @$(".community").hide();

  puliceity_receive: () ->
    @popover_basis("所有人多可以看到。")

  external_receive: () ->
    @popover_basis("显示给#{@find_owner()}圈子中的所有成员，以及这些成员的圈子中的所有人。")

  find_owner: () ->
    if @model.get("owner_type") == "User"
      @model.get("owner").login
    else
      @model.get("owner").name

  show_attachments: () ->
    _.each @model.get("attachments"), (atta) =>
      @$(".attachments").append("<img src='#{atta}' class='attachment' />")

  circle_receive: () ->
    @popover_basis('<h6 class="title-popover-topic">此信息目前的分享对象：</h6><div class="circle_users"></div>')
    @$circle_users_el = @$(".circle_users")
    @$circle_users_el.html("正在加载...")
    @model.receives (model, data) =>
      if data.length <= 0
        @$circle_users_el.html("暂时没有分享用户")
      else
        @show_user(data)

  show_user: (data) ->
    @$circle_users_el.html("")
    _.each data, (user) =>
      img_el = @avatar_img.clone().attr("src", user.icon)
      @$circle_users_el.append(img_el)
      img_el.tooltip(title: user.login)

  hide_receive: () ->
    @$(".status").popover("hide")

  popover_basis: (content) ->
    @$(".status").popover({
      content: content + "<a class='close-label'></a>",
      placement: "bottom",
      html: true
    }).popover("show")

class TopicViewList extends Backbone.View
  notice_el: $("<div class='alert alert-block'>暂时没有信息!</div>")

  events: {
    "click input:button.send_topic": "create",
    "keyup textarea[name=content]": "textarea_status"
  }

  initialize: (options) ->
    _.extend(@, options)

    @topic_list = new TopicList()
    @topic_list.seturl @remote_url
    @topic_list.bind("reset", @all_topic, @)
    #@topic_list.bind("add", @add_topic, @)

    @topic_list.fetch(data: {circle_id: @circle_id})

    @$form = @$("form.topic-form")
    @$button = $("input:button.send_topic", @$form)
    @$content = $("textarea[name=content]", @$form)

    @$el = $(@el)

  textarea_status: () ->
    content = @$content.val().trim()
    if content is ""
      @$button.addClass("disabled")
    else
      @$button.removeClass("disabled")

  create: () ->
    data = @form_serialize()
    return if data.content is ""

    data.friends = @get_friends()
    if data.friends.length <= 0
      @$(".friend-context input:text").focus()
      return

    @topic = new Topic(data)
    @topic.seturl @remote_url
    @topic.save({}, {
      data: $.param({topic: data})
      success: (model) =>
        @$content.val('')
        @textarea_status()
        topic = @topic_list.add(model).last()
        @before_append(@add_topic(topic))
        @$(".topic_upload").html('')

      error: (model, data) =>
        @show_error(JSON.parse(data.responseText))
    })

  form_serialize: () ->
    forms = @$form.serializeArray()
    data = {}
    $.each forms, (i, v) ->
      data[v.name] = v.value
    data

  before_append: (view) ->
    topics = @$(".topics>:first")
    if topics.length <= 0
      @$(".topics").append view
    else
      topics.before view

  all_topic: (collection) ->
    collection.each (model) =>
      @$(".topics").append @add_topic(model)

    @notice_msg()

  add_topic: (model) ->
    @notice_msg()
    model.seturl @remote_url
    topic_view = new TopicView(
      model: model,
      template: @template,
      current_user: @current_user
    )
    topic_view.render()

  notice_msg: () ->
    if @topic_list.length <= 0
      @$(".topics").append(@notice_el)
    else
      @notice_el.remove()

  show_error: (messages) ->
    $.each messages, (i, m) =>
      @$(".errors").append("#{m}")

    @$(".errors").show()

  get_friends: () ->
    items = @$(".chose-item-selector>.chose-label")
    data = []
    items.each (i, item) =>
      val = $.data(item, "data").value
      if typeof val is "string"
        data.push {id: val, status: "scope"}
      else
        data.push {id: val.id, status: val._status}

    data

root.TopicViewList = TopicViewList