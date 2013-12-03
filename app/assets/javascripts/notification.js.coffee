
root  = window || @

class  NotificationViewList extends Backbone.View

  initialize: () ->
    _.extend(@, @options)
    @collection_count = 0
    @urlRoot = "/people/#{@current_user_login}/notifications"
    @collection = new Backbone.Collection()
    # @transactions_contain_view = new TransactionContainer(parent_view: @)
    # @activitys_contain_view = new ActivityContainer(parent_view: @, login: @current_user_login)
    @collection.bind('add', @add_one, @)
    @collection.bind('remove', @remove_one, @)
    @collection.bind('reset', @add_all, @)
    @fetch()

    @client = window.clients
    #活动通知绑定
    @client.monitor_notification("/activities/arrived", @arrived(data))
    @client.monitor_notification("/activity/add", @add_activity(data))
    @client.monitor_notification("/activity/change", @change_activity(data))
    @client.monitor_notification("/activity/remove", @remove_activity(data))
    #用户关系
    @client.monitor_notification("/friends/add_quan", @add_to_circle(data))
    @client.monitor_notification("/friends/add_user", @add_user(data))
    @client.monitor_notification("/friends/remove_user", @remove_user(data)) 
    @client.monitor_notification("/friends/remove_quan", @remove_from_circle(data))
    #个人社交部分
    @client.monitor_notification("/follow", @follow_user(data))
    @client.monitor_notification("/unfollow", @unfollow_user(data))
    @client.monitor_notification("/request", @request_join_circle(data)) 
    @client.monitor_notification("/invite", @invite_join_circle(data))
    @client.monitor_notification("/refuse", @refuse_join_circle(data))
    @client.monitor_notification("/joined", @joined_success(data))
    @client.monitor_notification("/leaved", @leaved_circle(data)) 
    @client.monitor_notification("/like", @like_your(data))
    @client.monitor_notification("/unlike", @unlike_your(data))
    # 商店社交部分
    @client.monitor_notification("/shops/follow", @follow_shop(data))
    @client.monitor_notification("/shops/unfollow", @unfollow_shop(data))
    @client.monitor_notification("/shops/like", @like_shops_activity(data)) 
    @client.monitor_notification("/shops/unlike", @unlike_shops_activity(data))
    @client.monitor_notification("/shops/joined", @joined_shop_circle(data))
    @client.monitor_notification("/shops/leaved", @leaved_shop_circle(data))
    @client.monitor_notification("/shops/refuse", @refuse_join_shop_circle(data)) 
    @client.monitor_notification("/shops/request", @request_join_shop_circle(data))
    #评论
    @client.monitor_notification("/comments/add", @add_comment(data))
    @client.monitor_notification("/comments/update", @update_comment(data))
    @client.monitor_notification("/comments/remove", @remove_comment(data)) 

  #活动通知绑定
  arrived: (data) ->
    @collection.add(data)
    @change_notifications_count()

  change_activity: (data) ->
    @collection.add(data)
    @change_notifications_count()

  remove_activity: (data) ->
    @collection.add(data)
    @change_notifications_count()

  add_activity: (data) ->
    @collection.add(data)
    @change_notifications_count()

  #用户关系
  add_user: (data) ->
    @collection.add(data)
    @change_notifications_count()

  add_to_circle: (data) ->
    @collection.add(data)
    @change_notifications_count()
  remove_from_circle: (data) ->
    @collection.add(data)
    @change_notifications_count()

  remove_user: (data) ->
    @collection.add(data)
    @change_notifications_count()

  #个人社交部分
  follow_user: (data) ->
    @collection.add(data)
    @change_notifications_count()

  unfollow_user: (data) ->
    @collection.add(data)
    @change_notifications_count()

  like_shops_activity: (data) ->
    @collection.add(data)
    @change_notifications_count()

  unlike_shops_activity: (data) ->
    @collection.add(data)
    @change_notifications_count()

  joined_shop_circle: (data) ->
    @collection.add(data)
    @change_notifications_count()

  leaved_shop_circle: (data) ->
    @collection.add(data)
    @change_notifications_count()

  refuse_join_shop_circle: (data) ->
    @collection.add(data)
    @change_notifications_count()

  request_join_shop_circle: (data) ->
    @collection.add(data)
    @change_notifications_count()
  #評論
  add_comment: (data) ->
    @collection.add(data)
    @change_notifications_count()

  update_comment: (data) ->
    @collection.add(data)
    @change_notifications_count()

  remove_comment: (data) ->
    @collection.add(data)
    @change_notifications_count()

  change_notifications_count: () ->
    @$count.text(@collection_count)

  add_one: (model) ->
    new NotificationView(el: @el, model: model, url: @urlRoot)
    setTimeout( () =>
      pnotify(text: @model.get('body'), type: 'notice')
    ,5000)

  add_all: () ->
    @$count = $("#notification_count")
    if @collection_count <= 0
      @$count.remove()
    else
      @$count.text(@collection_count)

    @collection.each (model) =>
      info = model.attributes
      @collection.add(model)
      # if model.attributes.targeable_type == "Activity"
      #   @activitys_contain_view.collection.add(model)
      # else
      #   @transactions_contain_view.collection.add(model)
    @add_more()


  add_more: () ->
    if @collection_count > 10
      $(".notifications", @$el).append("<li><a href='#{@urlRoot}'>更多</a></li>")

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

  template: "<a href='url'>
              <span class='label label-warning'><i class='icon-info-sign'></i></span>
            {{ content }}</a>"
  events: 
    "click" : "mark_as_read"

  initialize: () ->
    _.extend(@, @options)
    @render()

  mark_as_read: () ->
    $.ajax(
      type: "post",
      url: "/#{ @url}/#{ @model.id }/mark_as_read",
      dataType: "json",
      success: () =>
        window.location.replace(@model.get('url'))
    )

  render: () ->
    $(@el).html(Hogan.compile(@template).render(@model))

class TransactionContainer extends Backbone.View

  initialize: () ->
    el = @options.parent_view.el
    @collection = new Backbone.Collection()
    @collection.bind('add', @add_one, @)

  add_one: (model) ->
    @transactions_view = new TransactionView({
      parent_el: @,
      model: model.attributes
    })
    $(@options.parent_view.el).find(".notifications").append(@transactions_view.render(model.toJSON()))


class TransactionView extends Backbone.View
  tagName: "li"
  className: "transactions_li"

  events:
    "click" : "direct_to_transaction_detail"

  template:
    "<a href='{{ url }}'>
      <span class='label label-warning'><i class='icon-info-sign'></i></span>
      {{ body }}
    </a>"

  render: (model) ->
    $(@el).html(Hogan.compile(@template).render(model))

  direct_to_transaction_detail: () ->
    url = @options.parent_el.options.parent_view.urlRoot
    $.ajax({
      type: "POST",
      dataType: "json",
      url: "#{ url }/#{ @model.id }/mark_as_read",
      success: () =>
        window.location.replace(@model.get('url'))
    })


class ActivityContainer extends Backbone.View

  initialize: () ->
    @el = @options.parent_view.el
    @collection = new Backbone.Collection()
    @collection.bind('add', @add_one, @)

  add_one: (model) ->
    @transactions_view = new ActivityViews({
      model: model.attributes,
      parent_view: @,
      login: @login
    })
    $(@el).find(".notifications").append(@transactions_view.render(model.toJSON()))

  remove_one: (id, el) ->
    model = @collection.get(id)
    @collection.remove model if model?
    $("#notification_count").html($("#notification_count").text() - 1)
    el.remove()


class ActivityViews extends Backbone.View
  tagName: "li"
  className: "activitys_li"

  events:
    "click " : "show_modal"

  template:
    "<a href='#'>
      <span class='label label-success'><i class='icon-bell-alt'></i></span>
      {{ body }}
    </a>"

  initialize: () ->
    _.extend(@, @options)

  show_modal: () ->
    activity_model = new ActivityModel({
      id: @model.targeable_id
    })

    activity_model.fetch success: (model) =>
      new ActivityView({
        model: model,
        el: $("#popup-layout"),
        login: @login
      }).modal()
    @remove()
    false

  render: (model) ->
    $(@el).html(Hogan.compile(@template).render(model))

  remove: () ->
    url = @parent_view.options.parent_view.urlRoot
    $.ajax(
      type: "POST",
      dataType: "json",
      url: "#{ url }/#{ @model.id }/mark_as_read",
      success: () =>
        @parent_view.remove_one(@model.id,@el)
    )


root.NotificationViewList = NotificationViewList