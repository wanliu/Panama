#describe: 主题
define ["jquery", "backbone", "timeago", "bootstrap_popover"], ($, Backbone) ->

  class Topic extends Backbone.Model
    seturl: (shop) ->
      @urlRoot = "/shops/#{shop}/admins/topics"

    constructor: (attr, shop) ->
      @seturl(shop)
      super attr

    receives: (callback) ->
      @fetch({
        url: "#{@urlRoot}/receives/#{@id}",
        success: callback
      })


  class TopicList extends Backbone.Collection
    model: Topic
    seturl: (shop) ->
      @url = "/shops/#{shop}/admins/topics"

    constructor: (models, shop) ->
      @seturl(shop)
      super models

  class TopicView extends Backbone.View
    avatar_img: $("<img class='img-circle user-avatar' />")

    events: {
      "click .external" : "external_receive",
      "click .circle" : "circle_receive",
      "click .close-label" : "hide_receive"
    }

    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @$el.html(@template.render(@model.toJSON()))
      @$(".user-info img.avatar").attr("src", @model.get("avatar_url"))
      @$("abbr.timeago").timeago()
      @puliceity_hide_status()

    render: () ->
      @$el

    puliceity_hide_status: () ->
      if @model.get("status") is "puliceity"
        @$(".puliceity").hide();

    external_receive: () ->
      @popover_basis('显示给您圈子中的所有成员，以及这些成员的圈子中的所有人。')

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

      @topic_list = new TopicList([], @shop)
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

      @topic = new Topic(data, @shop)
      @topic.save({}, {
        data: $.param({topic: data})
        success: (model) =>
          @$content.val('')
          @textarea_status()
          topic = @topic_list.add(model).last()
          @$(".topics>:first").before @add_topic(topic)

        error: (model, data) =>
          @show_error(JSON.parse(data.responseText))
      })

    form_serialize: () ->
      forms = @$form.serializeArray()
      data = {}
      $.each forms, (i, v) ->
        data[v.name] = v.value
      data

    all_topic: (collection) ->
      collection.each (model) =>
        @$(".topics").append @add_topic(model)

      @notice_msg()

    add_topic: (model) ->
      @notice_msg()
      model.seturl(@shop)
      topic_view = new TopicView(
        model: model,
        template: @template
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

  TopicViewList