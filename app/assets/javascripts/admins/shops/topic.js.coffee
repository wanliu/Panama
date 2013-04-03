#describe: 主题
define ["jquery", "backbone", "timeago"], ($, Backbone) ->

  class Topic extends Backbone.Model
    seturl: (shop) ->
      @urlRoot = "/shops/#{shop}/admins/topics"

    constructor: (attr, shop) ->
      @seturl(shop)
      super attr

  class TopicList extends Backbone.Collection
    seturl: (shop) ->
      @url = "/shops/#{shop}/admins/topics"

    constructor: (models, shop) ->
      @seturl(shop)
      super models

  class TopicView extends Backbone.View

    initialize: (options) ->
      _.extend(@, options)
      @$el = $(@el)
      @$el.html(@template.render(@model.toJSON()))
      @$(".user-info img.avatar").attr("src", @model.get("avatar_url"))
      @$("abbr.timeago").timeago()

    render: () ->
      @$el

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