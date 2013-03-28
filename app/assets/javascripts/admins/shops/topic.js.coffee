#describe: 主题
define ["jquery", "backbone"], ($, Backbone) ->

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

    render: () ->
      @$el

  class TopicViewList extends Backbone.View
    events: {
      "submit form.topic-form": "create"
    }

    initialize: (options) ->
      _.extend(@, options)

      @topic_list = new TopicList([], @shop)
      @topic_list.bind("reset", @all_topic, @)
      @topic_list.bind("add", @add_topic, @)
      @topic_list.fetch()

      @$content = @$("form.topic-form textarea[name=content]")

      @$el = $(@el)

    create: () ->
      content = @$content.val().trim()
      return false if content is ""

      data = { content: content }
      data.friends = @get_friends()
      @topic = new Topic(data, @shop)
      @topic.save({}, {
        success: _.bind(@add_one, @)
      })
      false

    all_topic: (collection) ->
      collection.each (model) =>
        @add_topic model


    add_topic: (model) ->
      topic_view = new TopicView(
        model: model,
        template: @template
      )
      @$(".topics").append(topic_view.render())

    get_friends: () ->
      items = @$(".chose-item-selector>.chose-label")
      data = []
      items.each (i, item) =>
        val = $.data(item, "data").values
        id = if typeof val is "string" then val else val.id
        data.push id
      data

  TopicViewList





