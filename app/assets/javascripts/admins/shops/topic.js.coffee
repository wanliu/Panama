#describe: 主题
define ["jquery", "backbone"], ($, Backbone) ->

  class Topic extends Backbone.Model
    seturl: (shop) ->
      @urlRoot = "/shops/#{shop}/admins/topics"

    constructor: (attr, shop) ->
      @seturl(shop)
      super attr

  class TopicView extends Backbone.View
    events: {
      "submit": "create"
    }

    initialize: (options) ->
      _.extend(@, options)

      @$el = $(@el)

    create: () ->
      content = @$("textarea[name=content]").val().trim()
      return false if content is ""

      data = { content: content }
      data.friends = @get_friends()
      @topic = new Topic(data, @shop)
      @topic.save()
      false

    get_friends: () ->
      items = @$(".chose-item-selector>.chose-label")
      data = []
      items.each (i, item) =>
        val = $.data(item, "data").values
        id = if typeof val is "string" then val else val.id
        data.push id
      data






