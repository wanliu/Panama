
root  = window || @

class InstantlyNotificationManager

  notify_target: "#notification_message i"

  defaultTemplate: Handlebars.compile(
        "<div class='noty_message'>" +
            "<img class='avatar noty_avatar' src='{{avatar}}' />" +
            "<span class='noty_text'></span>" +
            "<div class='noty_close'></div>" +
        "</div>")


  constructor: () ->
    @$notify_target = $(@notify_target)
    @plays = []

    @client = window.clients
    #活动通知绑定
    @client.monitor_notification("/activities/arrived", @arrived)
    @client.monitor_notification("/activity/add", @add_activity)
    @client.monitor_notification("/activity/change", @change_activity)
    @client.monitor_notification("/activity/remove", @remove_activity)
    #用户关系
    @client.monitor_notification("/friends/add_quan", @add_to_circle)
    @client.monitor_notification("/friends/add_user", @add_user)
    @client.monitor_notification("/friends/remove_user", @remove_user)
    @client.monitor_notification("/friends/remove_quan", @remove_from_circle)
    #个人社交部分
    @client.monitor_notification("/follow", @follow_user)
    @client.monitor_notification("/unfollow", @unfollow_user)
    @client.monitor_notification("/request", @request_join_circle)
    @client.monitor_notification("/invite", @invite_join_circle)
    @client.monitor_notification("/refuse", @refuse_join_circle)
    @client.monitor_notification("/joined", @joined_success)
    @client.monitor_notification("/leaved", @leaved_circle)
    @client.monitor_notification("/like", @like_your)
    @client.monitor_notification("/unlike", @unlike_your)
    # 商店社交部分
    @client.monitor_notification("/shops/follow", @follow_shop)
    @client.monitor_notification("/shops/unfollow", @unfollow_shop)
    @client.monitor_notification("/shops/like", @like_shops_activity)
    @client.monitor_notification("/shops/unlike", @unlike_shops_activity)
    @client.monitor_notification("/shops/joined", @joined_shop_circle)
    @client.monitor_notification("/shops/leaved", @leaved_shop_circle)
    @client.monitor_notification("/shops/refuse", @refuse_join_shop_circle)
    @client.monitor_notification("/shops/request", @request_join_shop_circle)
    #评论
    @client.monitor_notification("/comments/add", @add_comment)
    @client.monitor_notification("/comments/update", @update_comment)
    @client.monitor_notification("/comments/remove", @remove_comment)

    @notificationsList = NotificationViewList.getNotifiicationList()

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

  add_to_circle: (data) =>
    @addCommonNotif(data)


  remove_from_circle: (data) =>
    @addCommonNotif(data)

  remove_user: (data) =>
    @addCommonNotif(data)


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
  follow_shop: (data) ->
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
  add_comment: (data) =>
    @addCommonNotif(data)


  update_comment: (data) =>
    @addCommonNotif(data)


  remove_comment: (data) =>
    @addCommonNotif(data)

  addCommonNotif: (data) ->

    @addToPlays (callback) ->
      @notificationsList.collection.add(data)
      @notify({
        title: '有人关注了你',
        text: data.content,
        theme: 'notifyTheme',
        timeout: 5000,
        avatar: data.avatar,
        onClose: () ->
          callback()
        })
      # @collection_views.push(new NotificationView(parent_view: @el, model: data, url: @urlRoot))
      @change_notifications_count()

  addToPlays: (callback, delay = 3000) ->

    index = @plays.push [$.proxy(callback, this), delay]
    @playNotify()

  playNotify: () ->
    [callback, delay] = @plays[0]

    if @plays.length == 1
      callback () =>
        @plays.shift();
    else
      @playTimeoutId = setTimeout(()=>
        callback () =>
          @plays.shift();
          if @plays.length > 0
            @playNotify()
      , delay)

  change_notifications_count: () ->
    @$count = $("#notification_count")
    @$count.text(parseInt(@$count.text()) + 1)

  notify: (options) ->

    self = @
    options.template = @defaultTemplate(options)
    options.animation = {
            easing:'swing',
            speed:500
          }

    options.onClose = () ->
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

  template_realtime: "<a href='javascript:void(0)'><span class='label label-warning'><i class='icon-info-sign'></i></span>{{ content }}</a>"

  template_already: "<a href='javascript:void(0)'><span class='label label-warning'><i class='icon-info-sign'></i></span>{{ body }}</a></li>"

  events:
    "click" : "mark_as_read"


  initialize: () ->
    _.extend(@, @options)

  mark_as_read: () ->
    $.ajax(
      type: "post",
      url: "#{ @url}/#{ @model.id }/mark_as_read",
      dataType: "json",
      success: () =>
        window.location.replace(@model.get('url'))
    )

  render: () ->
    li = $(@el).append(Hogan.compile(@template_already).render(@model.attributes))
    @parent_view.find('ul').prepend(li)


class NotificationView extends NotificationViewBase

root.NotificationViewList = NotificationViewList