
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
    @current_user_login = @notificationsList.current_user_login
    @client = window.clients

    # 活动通知绑定
    # @client.monitor("/activities/arrived", @commonNotify)
    @client.monitor("/activities/add", @commonNotify) # √
    # @client.monitor("/activities/change", @commonNotify)
    # @client.monitor("/activities/remove", @commonNotify)
    @client.monitor("/activities/like", @commonNotify) # √
    @client.monitor("/activities/unlike", @commonNotify) # √
    # 用户关系
    @client.monitor("/friends/add_quan", @commonNotify) # √
    @client.monitor("/friends/add_user", @add_user) # √
    @client.monitor("/friends/remove_user", @remove_user) # √
    @client.monitor("/friends/remove_quan", @commonNotify) # √
    # 个人社交部分
    @client.monitor("/follow", @commonNotify) # √
    @client.monitor("/unfollow", @commonNotify) # √
    @client.monitor("/circles/request", @commonNotify) # √
    @client.monitor("/circles/invite", @commonNotify) # √
    @client.monitor("/circles/refuse", @commonNotify) # √
    @client.monitor("/circles/joined", @commonNotify) # √
    @client.monitor("/circles/leaved", @commonNotify) # √
    # 商店社交部分
    @client.monitor("/shops/follow", @commonNotify) # √
    @client.monitor("/shops/unfollow", @commonNotify) # √
    @client.monitor("/shops/like", @commonNotify) #暂时不需要实现
    @client.monitor("/shops/unlike", @commonNotify) #暂时不需要实现
    @client.monitor("/shops/joined", @commonNotify) # √
    @client.monitor("/shops/leaved", @commonNotify) # √
    @client.monitor("/shops/refuse", @commonNotify) 
    @client.monitor("/shops/request", @commonNotify) #暂时不需要实现
    @client.monitor("/employees/invite", @commonNotify) # √ 
    # 评论
    # @client.monitor("/comments/add", @commonNotify)
    @client.monitor("/comments/mention", @commonNotify) # √
    # @client.monitor("/comments/update", @commonNotify)
    # @client.monitor("/comments/remove", @commonNotify)

    #求购 
    @client.monitor("/answer_ask_buy", @commonNotify)
    @client.monitor("/shops/answer_ask_buy/failer", @commonNotify)
    @client.monitor("/shops/answer_ask_buy/success", @commonNotify)

    #交易订单
    @client.monitor("/shops/transactions/create", @commonNotify)
    @client.monitor("/shops/transactions/destroy", @commonNotify)    
    @client.monitor("/shops/transactions/dispose", @commonNotify)
    @client.monitor("/shops/transactions/change_state", @commonNotify)

    @client.monitor("/transactions/destroy", @commonNotify)
    @client.monitor("/transactions/change_state", @commonNotify)
    @client.monitor("/transactions/change_delivery_price", @commonNotify)


    #直接订单
    @client.monitor("/shops/direct_transactions/create", @commonNotify)
    @client.monitor("/shops/direct_transactions/dispose", @commonNotify)
    @client.monitor("/shops/direct_transactions/destroy", @commonNotify)
    @client.monitor("/shops/direct_transactions/change_state", @commonNotify)

    @client.monitor("/direct_transactions/destroy", @commonNotify)
    @client.monitor("/direct_transactions/change_state", @commonNotify)

    #退货
    @client.monitor("/order_refunds/create", @commonNotify)    
    @client.monitor("/order_refunds/change_state", @commonNotify)

  add_user: (data) =>
    @commonNotify(data)
    model = new ChatModel({
      follow_type: 1,
      login: data.friend_name,
      icon: data.avatar
    })
    ChatManager.getInstance().addChatIcon(model)

  remove_user: (data) =>
    @commonNotify(data)
    model = new ChatModel({
      follow_type: 1,
      login: data.friend_name,
      icon: data.avatar
    })
    ChatManager.getInstance().removeChatIcon(model)

  commonNotify: (data) =>
    @addToPlays data, (info) =>
      console.log(info)
      @notificationsList.collection.add(info)
      @notify({
        id: info.id,
        title: info.title,
        text: info.content,
        avatar: info.avatar
      })

  addToPlays: (data, callback, delay = 3000) =>
    index = @plays.push [callback, delay, data]

  playNotify: () =>
    if @plays.length > 0
      [animation, delay, info] = @plays.shift()
      animation(info) if animation && _.isFunction(animation)

  notify: (options) =>
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
    self = @
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
    options.callback.onCloseClick = (options) ->
      $url = "/people/#{self.current_user_login}/notifications/#{ @options.id}/mark_as_read"
      window.location.href = $url

    pnotify(options)

class root.NotificationViewList extends Backbone.View

  @startup = (options) ->
    @instance ||= new NotificationViewList(options)
    @instanceManager = new NotificationManager()

  @getInstance = () ->
    @instance

  initialize: () ->
    _.extend(@, @options)
    @$count = @$("#notification_count")
    @urlRoot = "/people/#{@current_user_login}/notifications"
    @collection = new Backbone.Collection()
    @collection.bind('add', @add_one, @)
    @collection.bind('remove', @remove_one, @)
    @collection.bind('reset', @add_all, @)
    @fetch()

  add_one: (model) ->
    _.sortBy(this.collection.models)
    view = new NotificationView(parent_view: @, model: model, url: @urlRoot)
    @$('ul').prepend(view.render().el)
    model.view = view
    @change_count()

  remove_one: (model) ->
    $(model.view.el).fadeOut()
    @add_all()

  add_all: () ->
    @$('ul').html('')
    _.each @collection.models, (model, index, list) =>
      # 显示最近的通知
      if @collection.length - index <= 10
        @add_one(model)
    @add_more()
    @change_count()

  change_count: () ->
    @$count.html(@collection.length)
    if @collection.length <= 0
      @$count.hide()
    else
      @$count.show()

  add_more: () ->
    @$(".notifications").append("
      <li class='pull-right'>
        <a class='href_url check_all' href='#{@urlRoot}'>查看所有>>></a>
      </li>")

  fetch: () ->
    @collection.fetch(
      url: "#{@urlRoot}/unreads",
      data: { offset: 0 } 
    )


class NotificationView extends Backbone.View
  tagName: "li"

  template_already: Handlebars.compile("
    <label title='标为已读' class='href_url mark_read'>
      <i class='icon-check'></i>
    </label>
    <a href='javascript:void(0)' class='href_url content'>
      {{ content }}
    </a>")

  events:
    'click .mark_read': 'mark_as_read'
    'click .content'  : 'read_message'

  initialize: () ->
    _.extend(@, @options)
    @fetch_url = "#{@url}/#{@model.id}/mark_as_read"
    @render()

  mark_as_read: (event) ->
    event.stopPropagation() # Keep dropdown open on click
    $.ajax(
      type: 'post',
      dataType: 'json',
      url: @fetch_url,
      success: (data, xhr, res) =>
        @parent_view.collection.remove(@model)
    )

  read_message: () ->
    return pnotify(text: '跳转地址为空', type: 'error') unless @fetch_url 
    window.location.href = @fetch_url

  render: () ->
    $(@el).html(@template_already(@model.attributes))
    @

