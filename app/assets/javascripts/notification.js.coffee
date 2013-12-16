
root  = window || @

class InstantlyNotificationManager

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
    @$notify_target = $(@notify_target)
    @plays = []

    @client = window.clients
    #活动通知绑定
    @client.monitor("/activities/arrived", @arrived)
    @client.monitor("/activities/add", @add_activity) # x
    @client.monitor("/activities/change", @change_activity)
    @client.monitor("/activities/remove", @remove_activity)
    #用户关系
    @client.monitor("/friends/add_quan", @add_to_circle) # √
    @client.monitor("/friends/add_user", @add_user) # √
    @client.monitor("/friends/remove_user", @remove_user) # √
    @client.monitor("/friends/remove_quan", @remove_from_circle) # √
    #个人社交部分
    @client.monitor("/follow", @follow_user) # √
    @client.monitor("/unfollow", @unfollow_user) # √
    @client.monitor("/circles/request", @request_join_circle) # x
    @client.monitor("/circles/invite", @invite_join_circle) # √
    @client.monitor("/circles/refuse", @refuse_join_circle)
    @client.monitor("/circles/joined", @joined_success) # √
    @client.monitor("/circles/leaved", @leaved_circle) # √
    @client.monitor("/activities/like", @like_your) # √
    @client.monitor("/activities/unlike", @unlike_your) # x
    # 商店社交部分

    @client.monitor("/shops/follow", @follow_shop) # √
    @client.monitor("/shops/unfollow", @unfollow_shop) # √
    @client.monitor("/shops/like", @like_shops_activity)
    @client.monitor("/shops/unlike", @unlike_shops_activity)
    @client.monitor("/shops/joined", @joined_shop_circle)
    @client.monitor("/shops/leaved", @leaved_shop_circle)
    @client.monitor("/shops/refuse", @refuse_join_shop_circle)
    @client.monitor("/shops/request", @request_join_shop_circle)
    #评论
    # @client.monitor("/comments/add", @add_comment)
    @client.monitor("/comments/mention", @mention_comment)
    # @client.monitor("/comments/update", @update_comment)
    # @client.monitor("/comments/remove", @remove_comment)

    @notificationsList = NotificationViewList.getNotifiicationList()

    @playId = setInterval(@playNotify, 3000)

  #活动通知绑定
  arrived: (data) =>
    @addCommonNotif(data)

  change_activity: (data) =>
    @addCommonNotif(data)

  remove_activity: (data) =>
    @addCommonNotif(data)

  add_activity: (data) =>
    @addCommonNotif(data)

  #用户关系
  add_user: (data) =>
    @addCommonNotif(data)

    chatList = ChatListView.getInstance()

    if chatList?
      friendsView = chatList.friends_view

      friendsView.addFriend(
        follow_type: 1,
        login: data.friend_name,
        icon: data.avatar
      )


  add_to_circle: (data) =>
    @addCommonNotif(data)


  remove_from_circle: (data) =>
    @addCommonNotif(data)

  remove_user: (data) =>
    @addCommonNotif(data)

    chatList = ChatListView.getInstance()

    if chatList?
      friendsView = chatList.friends_view

      friendsView.removeFriend(
        follow_type: 1,
        login: data.friend_name,
        icon: data.avatar
      )


  #个人社交部分
  follow_user: (data) =>
    @addCommonNotif(data)


  unfollow_user: (data) =>
    @addCommonNotif(data)


  request_join_circle: (data) =>
    @addCommonNotif(data)


  invite_join_circle: (data) =>
    @addCommonNotif(data)


  refuse_join_circle: (data) =>
    @addCommonNotif(data)


  joined_success: (data) =>
    @addCommonNotif(data)


  leaved_circle: (data)=>
    @addCommonNotif(data)


  like_your: (data) =>
    @addCommonNotif(data)


  unlike_your: (data) =>
    @addCommonNotif(data)

  # 商店社交部分
  follow_shop: (data) =>
    @addCommonNotif(data)

  unfollow_shop: (data) =>
    @addCommonNotif(data)

  like_shops_activity: (data) =>
    @addCommonNotif(data)

  unlike_shops_activity: (data) =>
    @addCommonNotif(data)


  joined_shop_circle: (data) =>
    @addCommonNotif(data)


  leaved_shop_circle: (data) =>
    @addCommonNotif(data)


  refuse_join_shop_circle: (data) =>
    @addCommonNotif(data)


  request_join_shop_circle: (data) =>
    @addCommonNotif(data)

  #評論
  mention_comment: (data) =>
    @addCommonNotif(data)

  # add_comment: (data) =>
  #   @addCommonNotif(data)


  # update_comment: (data) =>
  #   @addCommonNotif(data)


  # remove_comment: (data) =>
  #   @addCommonNotif(data)

  addCommonNotif: (data) ->
    @addToPlays data, (info) =>
      console.log(info)
      @notificationsList.collection.add(info)
      @notify({
        title: info.title,
        text: info.content,
        avatar: info.avatar
      })
      # @collection_views.push(new NotificationView(parent_view: @el, model: data, url: @urlRoot))

  addToPlays: (data, callback, delay = 3000) ->

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
              easing:'swing',
              speed:500
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

class NotificationViewList extends Backbone.View

  @startup = (options) ->
    @__notifications_list ||= new NotificationViewList(options)
    @InstantlyManager = new InstantlyNotificationManager

  @getNotifiicationList = () ->
    @__notifications_list

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
    @notification_view_realtime = new NotificationView(parent_view: @el, model: model, url: @urlRoot)
    @notification_view_realtime.render()

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
      @notification_view_already = new NotificationView(parent_view: @el, model: model, url: @urlRoot)
      @notification_view_already.render()

  add_more: () ->
    if @collection_count > 10
      $(".notifications", @$el).append("<li><a href='#{@urlRoot}'>更多>>></a></li>")

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


class NotificationViewBase extends Backbone.View
  tagName: "li"

  template_realtime: Handlebars.compile("<a href='javascript:void(0)'><span class='label label-warning'><i class='icon-info-sign'></i></span>&nbsp;{{ content }}</a>")

  template_already: Handlebars.compile("<a href='javascript:void(0)'><span class='label label-warning'><i class='icon-info-sign'></i></span>&nbsp;{{ content }}</a></li>")

  events:
    "click" : "read_message"


  initialize: () ->
    _.extend(@, @options)

  read_message: () ->
    $.ajax(
      type: "post",
      dataType: "json",
      url: "#{ @url}/#{ @model.id }/mark_as_read",
      success: (data, xhr, res) =>
        url = data.url
        return pnotify(text: '跳转地址为空', type: 'error') unless url 
        window.location.href = url
    )

  render: () ->
    li = $(@el).append(@template_already(@model.attributes))
    @parent_view.find('ul').prepend(li)


class NotificationView extends NotificationViewBase

root.NotificationViewList = NotificationViewList