
root  = window || @

class NotificationManager

  notify_target: "#notification_message i"

  defaultTemplate: Handlebars.compile(
     """<div class='noty_message'>
          <img class='avatar avatar-icon noty_avatar' src='{{avatar}}' />
          {{#if title}}
            <p>{{title}}</p>
          {{/if}}
          <span class='noty_text'></span>
          <div class='noty_close'></div>
      </div>""")

  constructor: () ->
    @plays = []
    setInterval(@playNotify, 3000)
    @$notify_target = $(@notify_target)
    @notificationsList = NotificationViewList.getInstance()
    @client = window.clients

    #活动通知绑定
    @client.monitor("/activities/arrived", @commonNotify)
    @client.monitor("/activities/add", @commonNotify) # x
    @client.monitor("/activities/change", @commonNotify)
    @client.monitor("/activities/remove", @commonNotify)
    #用户关系
    @client.monitor("/friends/add_quan", @commonNotify) # √
    @client.monitor("/friends/add_user", @add_user) # √
    @client.monitor("/friends/remove_user", @remove_user) # √
    @client.monitor("/friends/remove_quan", @commonNotify) # √
    #个人社交部分
    @client.monitor("/follow", @commonNotify) # √
    @client.monitor("/unfollow", @commonNotify) # √
    @client.monitor("/circles/request", @commonNotify) # x
    @client.monitor("/circles/invite", @commonNotify) # √
    @client.monitor("/circles/refuse", @commonNotify)
    @client.monitor("/circles/joined", @commonNotify) # √
    @client.monitor("/circles/leaved", @commonNotify) # √
    @client.monitor("/activities/like", @commonNotify) # √
    @client.monitor("/activities/unlike", @commonNotify) # x
    # 商店社交部分
    @client.monitor("/shops/follow", @commonNotify) # √
    @client.monitor("/shops/unfollow", @commonNotify) # √
    @client.monitor("/shops/like", @commonNotify)
    @client.monitor("/shops/unlike", @commonNotify)
    @client.monitor("/shops/joined", @commonNotify)
    @client.monitor("/shops/leaved", @commonNotify)
    @client.monitor("/shops/refuse", @commonNotify)
    @client.monitor("/shops/request", @commonNotify)
    #评论
    # @client.monitor("/comments/add", @commonNotify)
    @client.monitor("/comments/mention", @commonNotify)
    # @client.monitor("/comments/update", @commonNotify)
    # @client.monitor("/comments/remove", @commonNotify)

  add_user: (data) =>
    @commonNotify(data)
    chatList = ChatListView.getInstance()
    if chatList?
      friendsView = chatList.friends_view

      friendsView.addFriend(
        follow_type: 1,
        login: data.friend_name,
        icon: data.avatar
      )

  remove_user: (data) =>
    @commonNotify(data)
    chatList = ChatListView.getInstance()
    friendsView = chatList.friends_view
    friendsView.removeFriend(
      follow_type: 1,
      login: data.friend_name,
      icon: data.avatar
    )

  commonNotify: (data) =>
    @addToPlays data, (info) =>
      console.log(info)
      @notificationsList.collection.add(info)
      @notify({
        title: info.title,
        text: info.content,
        avatar: info.avatar
      })
      # @collection_views.push(new NotificationView(parent_view: @el, model: data, url: @urlRoot))

  addToPlays: (data, callback, delay = 3000) =>
    index = @plays.push [callback, delay, data]

  playNotify: () =>
    if @plays.length > 0
      [animation, delay, info] = @plays.shift()
      animation(info) if animation && _.isFunction(animation)

  change_count: () ->
    @$count = $("#notification_count")
    @$count.text(parseInt(@$count.text()) + 1)

  notify: (options) ->
    self = @
    unless options.hasOwnProperty('theme')
      options.theme = 'notifyTheme'

    unless options.hasOwnProperty('timeout')
      options.timeout = 5000

    unless options.hasOwnProperty('template')
      options.template = @defaultTemplate(options)

    unless options.hasOwnProperty('animation')
      options.animation = {
              easing: 'swing',
              speed: 500
            }

    options.callback || = {}
    options.callback.onClose = () ->
      pos = @$bar.offset()
      target_pos = self.$notify_target.offset()
      scrollTop = $(window).scrollTop()
      scrollLeft = $(window).scrollLeft()

      @options.animation.close = {
        # opacity: 0,
        top: target_pos.top - scrollTop + 10,
        left: target_pos.left - scrollLeft + 10,
        width: '5px',
        height: '5px'
      }

      @$bar.css('position', 'fixed')
           .css('top', pos.top - scrollTop)
           .css('left', pos.left - scrollLeft)

    options.animation.open = {
      opacity: 1,
    }
    pnotify(options)

  # bubble_notice: () ->
  #   target = $(".bumbble_notice")
  #   target.removeData("popover")
  #   target.popover({
  #     title: "你有新的消息"
  #     content: @model.attributes.content,
  #     container: '.bumbble_notice',
  #   })
  #   target.popover('show')
  #   target.find(".popover")

class root.NotificationViewList extends Backbone.View

  @startup = (options) ->
    @instance ||= new NotificationViewList(options)
    @InstantlyManager = new NotificationManager

  @getInstance = () ->
    @instance

  initialize: () ->
    _.extend(@, @options)
    @collection_count = 0
    @urlRoot = "/people/#{@current_user_login}/notifications"
    @collection_views = []
    @collection = new Backbone.Collection()
    @collection.bind('add', @add_one, @)
    @collection.bind('remove', @remove_one, @)
    @collection.bind('reset', @add_all, @)
    @fetch()

  add_one: (model) ->
    new NotificationView(parent_view: @el, model: model, url: @urlRoot)

  add_all: () ->
    @$count = $("#notification_count")
    if @collection_count <= 0
      @$count.remove()
    else
      @$count.text(@collection_count)
    @render_all(@collection)
    @add_more()

  render_all: (collection) ->
    collection.each (model) =>
      @add_one(model)

  add_more: () ->
    @$(".notifications").append("
      <li class='pull-right'>
        <a class='href_url' href='#{@urlRoot}'>查看所有>>></a>
      </li>")

  fetch_data: (count) ->
    @collection_count = count
    @collection.fetch(data: {limit: 10, offset: 0}, url: "#{@urlRoot}/unreads")

  fetch: () ->
    $.ajax(
      url: "#{@urlRoot}/unread_count",
      dataType: "json"
      success: (data) =>
        @fetch_data(data.count)
    )


class NotificationView extends Backbone.View
  tagName: "li"

  template_realtime: Handlebars.compile("
    <span class='label label-warning'>
      <i class='icon-info-sign'></i>
    </span>
    <a href='javascript:void(0)' class='href_url'>
      {{ content }}
    </a>")

  template_already: Handlebars.compile("
    <span class='label label-warning'>
      <i class='icon-info-sign'></i>
    </span>
    <a href='javascript:void(0)' class='href_url'>
      {{ content }}
    </a>")

  events:
    "click .href_url" : "read_message"

  initialize: () ->
    _.extend(@, @options)
    @render()

  read_message: () ->
    $.ajax(
      type: "post",
      dataType: "json",
      url: "#{@url}/#{@model.id}/mark_as_read",
      success: (data, xhr, res) =>
        url = data.url
        return pnotify(text: '跳转地址为空', type: 'error') unless url 
        window.location.href = url
    )

  render: () ->
    li = $(@el).append(@template_already(@model.attributes))
    @parent_view.find('ul').prepend(li)

