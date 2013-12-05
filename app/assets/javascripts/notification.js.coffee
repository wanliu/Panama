
root  = window || @

class  NotificationViewList extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @collection_count = 0
    @urlRoot = "/people/#{@current_user_login}/notifications"
    @collection = new Backbone.Collection()
    @collection.bind('add', @add_one, @)
    @collection.bind('remove', @remove_one, @)
    @collection.bind('reset', @add_all, @)
    @fetch()

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

  #活动通知绑定
  arrived: (data) =>
    @collection.add(data)
    @change_notifications_count()

  change_activity: (data) =>
    @collection.add(data)
    @change_notifications_count()

  remove_activity: (data) =>
    @collection.add(data)
    @change_notifications_count()

  add_activity: (data) =>
    @collection.add(data)
    @change_notifications_count()

  #用户关系
  add_user: (data) =>
    @collection.add(data)
    @change_notifications_count()

  add_to_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  remove_from_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  remove_user: (data) =>
    @collection.add(data)
    @change_notifications_count()

  #个人社交部分
  follow_user: (data) =>
    @collection.add(data)
    @change_notifications_count()

  request_join_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  invite_join_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  refuse_join_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  joined_success: (data) =>
    @collection.add(data)
    @change_notifications_count()

  leaved_circle: (data)=>
    @collection.add(data)
    @change_notifications_count()

  like_your: (data) =>
    @collection.add(data)
    @change_notifications_count()

  unlike_your: (data) =>
    @collection.add(data)
    @change_notifications_count()

  # 商店社交部分
  follow_shop: (data) ->
    @collection.add(data)
    @change_notifications_count()

  unfollow_shop: (data) =>
    @collection.add(data)
    @change_notifications_count()

  like_shops_activity: (data) =>
    @collection.add(data)
    @change_notifications_count()

  unlike_shops_activity: (data) =>
    @collection.add(data)
    @change_notifications_count()

  joined_shop_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  leaved_shop_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  refuse_join_shop_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()

  request_join_shop_circle: (data) =>
    @collection.add(data)
    @change_notifications_count()
  #評論
  add_comment: (data) =>
    @collection.add(data)
    @change_notifications_count()

  update_comment: (data) =>
    @collection.add(data)
    @change_notifications_count()

  remove_comment: (data) =>
    @collection.add(data)
    @change_notifications_count()

  change_notifications_count: () ->
    @$count = $("#notification_count")
    @$count.text(parseInt(@$count.text()) + 1)

  add_one: (model) ->
    @notification_view_realtime = new NotificationView(parent_view: @el, model: model, url: @urlRoot)
    @notification_view_realtime.render_realtime()

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
      @notification_view_already.render_already()

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

class NotificationView extends Backbone.View
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

  render_already: () ->
    li = $(@el).append(Hogan.compile(@template_already).render(@model.attributes))
    @parent_view.find('ul').prepend(li)


  render_realtime: () ->
    li = $(@el).append(Hogan.compile(@template_realtime).render(@model.attributes))
    @parent_view.find('ul').prepend(li)
    @bubble_notice()

  bubble_notice: () ->
    target = $(".bumbble_notice")
    target.removeData("popover")
    target.popover({
      title: "你有新的消息"
      content: @model.attributes.content,
      container: '.bumbble_notice'
    })
    target.popover('show')
    target.find(".popover")

root.NotificationViewList = NotificationViewList