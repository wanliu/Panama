#= require chosen_tool
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
          <div>
            <a class="pull-right btn btn-primary i_know" href="javascript:void(0)">我知道了</a>
            <a href="{{ url }}" class='btn btn-danger pull-right'>查看</a>
          </div>
      </div>""")

  followTemplate: Handlebars.compile(
    """<div class='noty_message noty_message_follow'>
        <img class='avatar avatar-icon noty_avatar' src='{{avatar}}' />
        <span class='noty_text'></span>
        <div>
          <div class='noty_close'></div>
          <a href="{{ url }}" class='btn btn-danger pull-right'>查看对方</a>
          <button data-value-id="{{ user_id }}" class='follow btn btn-primary pull-right'>回关注</button>
        </div>
      </div>""")
  
  shopFollowTempate: Handlebars.compile(
    """<div class='noty_message'>
        <img class='avatar avatar-icon noty_avatar' src='{{avatar}}' />
        <span class='noty_text'></span>
        <div>
          <div class='noty_close'></div>
          <a href="{{ url }}" class='btn btn-danger pull-right'>查看</a>
          <a  href='/shops/{{ shop_name }}/shop_circles' data-toggle='modal' data-dismiss='modal' class="btn btn-primary pull-right" data-target='#choseCircle'>
            邀请加入商圈
          </a>
        </div>
      </div>""")

  circleInviteTemplate: Handlebars.compile(
    """<div class='noty_message'>
        <img class='avatar avatar-icon noty_avatar' src='{{avatar}}' />
        <span class='noty_text'></span>
        <div>
          <div class='noty_close'></div>
          <button  class='btn btn-danger pull-right agree'>同意</button>
          <button class="btn btn-primary pull-right refuse" >拒绝</button>
        </div>
      </div>""")

  activityTemplate: Handlebars.compile(
    """<div class='noty_message'>
        <img class='avatar avatar-icon noty_avatar' src='{{avatar}}' />
        <span class='noty_text'></span>
        <div class='noty_close'></div>
        <div class='activity' activity-id="{{ target.id }}">
          <a class="pull-right btn btn-primary i_know" href="javascript:void(0)">我知道了</a>
          <a href="javascript:void(0)" class='btn btn-danger pull-right preview'>查看</a>
        </div>
      </div>""")

  askBuyTemplate: Handlebars.compile(
   """<div class='noty_message'>
          <img class='avatar avatar-icon noty_avatar' src='{{avatar}}' />
          <span class='noty_text'></span>
          <div class='noty_close'></div>
          <div class='ask_buy' ask-buy-id="{{ ask_buy_id }}">
            <a class="pull-right btn btn-primary i_know" href="javascript:void(0)">我知道了</a>
            <a href="javascript:void(0)" class='btn btn-danger pull-right preview '>查看求购</a>
          </div>
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
    @client.monitor("/activities/add", @activity) # √
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
    @client.monitor("/follow", @follow) # √
    @client.monitor("/unfollow", @commonNotify) # √
    @client.monitor("/circles/request", @commonNotify) # √
    @client.monitor("/circles/invite", @circle_invite) # √
    @client.monitor("/circles/refuse", @commonNotify) # √
    @client.monitor("/circles/joined", @commonNotify) # √
    @client.monitor("/circles/leaved", @commonNotify) # √
    # 商店社交部分
    @client.monitor("/shops/follow", @shop_follow) # √
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
    @client.monitor("/answer_ask_buy", @answer_ask_buy)
    @client.monitor("/shops/answer_ask_buy/failer", @commonNotify)
    @client.monitor("/shops/answer_ask_buy/success", @commonNotify)

    #交易订单
    @client.monitor("/shops/transactions/create", @commonNotify)
    @client.monitor("/shops/transactions/destroy", @commonNotify)    
    @client.monitor("/shops/transactions/dispose", @orderNotify)
    @client.monitor("/shops/transactions/change_state", @orderNotify)

    @client.monitor("/transactions/destroy", @commonNotify)
    @client.monitor("/transactions/change_state", @orderNotify)
    @client.monitor("/transactions/change_info", @commonNotify)


    #直接订单
    @client.monitor("/shops/direct_transactions/create", @commonNotify)
    @client.monitor("/shops/direct_transactions/dispose", @directNotify)
    @client.monitor("/shops/direct_transactions/destroy", @commonNotify)
    @client.monitor("/shops/direct_transactions/change_state", @directNotify)

    @client.monitor("/direct_transactions/destroy", @commonNotify)
    @client.monitor("/direct_transactions/change_state", @directNotify)

    #退货
    @client.monitor("/order_refunds/create", @commonNotify)    
    @client.monitor("/order_refunds/change_state", @refundNotify)
    @client.monitor("/order_refunds/change_info", @commonNotify)

    @client.monitor("/shops/order_refunds/change_info", @commonNotify)

  orderNotify: (data) =>
    @commonNotify(data) if data.order_id.toString() != @getTypeId("order")

  directNotify: (data) =>    
    @commonNotify(data) if data.direct_id.toString() != @getTypeId("direct")
      
  refundNotify: (data) =>    
    @commonNotify(data) if data.refund_id.toString() != @getTypeId("refund")

  getTypeId: (type) ->
    type_id = notifyDisposeState.getType(type) || ""
    type_id.toString()

  close_message: () ->

  answer_ask_buy: (data) =>
    data.template = $(@askBuyTemplate(data))
    @commonNotify(data)
    new AskBuyPreview({
      el: data.template,
      login: @current_user_login
    })
    new DefaultView({ el: data.template})

  activity: (data) =>
    data.template = $(@activityTemplate(data))
    @commonNotify(data)
    new ActivityPreview({
      el: data.template,
      login: @current_user_login
    })
    new DefaultView({ el: data.template})

  circle_invite: (data) =>
    data.template = $(@circleInviteTemplate(data))
    @commonNotify(data)
    new AnswerInvite({
      el: data.template,
      invite: data.invite,
    })


  shop_follow: (data) =>
    data.template = $(@shopFollowTempate(data))
    @commonNotify(data)
    invite_view = new InviteManyView({
      el: $(".circle_invite_list"),
      shop_name: data.shop_name,
      user_id: data.user.id
    })
    # invite_view.trigger( "close_message",'invite_user');

  follow: (data) =>
    data.template = $(@followTemplate(data))
    @commonNotify(data)
    new FollowView({
      data: {
        follow_id:  data.user.id,
        follow_type: "User"
      },
      login: @current_user_login,
      el: data.template
    })

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
    unless data.template? 
      data.template = $(@defaultTemplate(data))
      new DefaultView({ el: data.template})

    @addToPlays data, (info) =>
      console.log(info)
      _user_id = info.user.id if info.user?
      _shop_name = info.shop_name if info.shop_name?
      _tempalte = info.template if info.template?
      @notificationsList.collection.add(info)
      @notify({
        button: $(".noty_close")
        template: _tempalte,
        id: info.id,
        title: info.title,
        text: info.content,
        avatar: info.avatar,
        user_id: _user_id,
        shop_name: _shop_name,
        url:  "/people/#{@current_user_login}/notifications/"+info.id+"/mark_as_read",
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
      options.timeout = false

    unless options.hasOwnProperty('template') && options.template?
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
    pnotify(options)

class DefaultView extends Backbone.View
  events:
    "click .i_know" : "close_message"

  close_message: () ->
    @$(".noty_close").click()

class InviteManyView extends Backbone.View
  events: 
    "click .invite_user" : "invite_user"

  initialize: (options) ->
    _.extend(@, options)
    @el = $(@el)
    @tool_view = new chosenTool({
      el: @el
    })

  invite_user: (e) =>
    return false if @$(".disabled").length == 1
    $(e.currentTarget).addClass("disabled")
    ids = @tool_view.data()
    $.ajax({
      type: "POST",
      data: {ids: ids, user_id: @user_id},
      url: "/shops/"+@shop_name+"/admins/communities/invite_people",
      success: () =>
        pnotify(text: "邀请成功，等待对方确认......")
        @$(".noty_close").click()
        @el.modal("hide")
      error: (message) ->
        pnotify(text: JSON.parse(message.responseText), type: "error")
    })

class AnswerInvite extends Backbone.View
  events:
    "click .agree"   :  "agree_invite"
    "click .refuse"  :  "refuse_invite"

  agree_invite: () =>
    $.ajax({
      dataType: "json",
      type: "post",
      url: "/communities/#{@options.invite.targeable_id}/invite/#{ @options.invite.id }/agree_join",
      success: () =>
        @$(".noty_close").click()
        pnotify(text: "加入商圈成功.....")
    })
  refuse_invite: () =>
    $.ajax({
      dataType: "json",
      type: "post",
      url: "/communities/#{@options.invite.targeable_id}/invite/#{ @options.invite.id }/refuse_join",
      success: () =>
        @$(".noty_close").click()
        pnotify(text: "拒绝加入商圈成功.....")
    })

class root.NotificationViewList extends Backbone.View

  @startup = (options) ->
    @instance ||= new NotificationViewList(options)
    @instanceManager ||= new NotificationManager()

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

