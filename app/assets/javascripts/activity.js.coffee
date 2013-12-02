# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require ask_buy_preview
#= require product_preview
#= require shop_products
#= require lib/infinite_scroll
#= require_tree ./activities
#= require activity_buy
#= require lib/bootstrap-progressbar
#= require activity_bind

root = window || @

ANIMATES = ["flash", "bounce", "shake", "tada", "swing", "wobble", "wiggle", "pulse",
      "flip", "flipInX", "flipOutX", "flipInY", "flipOutY", "fadeIn", "fadeInUp",
      "fadeInDown", "fadeInLeft", "fadeInRight", "fadeInUpBig", "fadeInDownBig",
      "fadeInLeftBig", "fadeInRightBig", "fadeOut", "fadeOutUp", "fadeOutDown",
      "fadeOutLeft", "fadeOutRight", "fadeOutUpBig", "fadeOutDownBig", "fadeOutLeftBig",
      "fadeOutRightBig", "bounceIn", "bounceInDown", "bounceInUp", "bounceInLeft",
      "bounceInRight", "bounceOut", "bounceOutDown", "bounceOutUp", "bounceOutLeft",
      "bounceOutRight", "rotateIn", "rotateInDownLeft", "rotateInDownRight", "rotateInUpLeft",
      "rotateInUpRight", "rotateOut", "rotateOutDownLeft", "rotateOutDownRight", "rotateOutUpLeft",
      "rotateOutUpRight", "lightSpeedIn", "lightSpeedOut", "hinge", "rollIn", "rollOut",]

class ActivityView extends Backbone.View

  events:
    "click [data-dismiss=modal]"    : "close"
    "click .animate-play"           : "playAnimate"
    "click .load_modal"             : "load_modal"
    "click .share_activity"         : "share_activity"

  initialize: (@options) ->
    _.extend(@, @options)
    @$dialog = $("<div class='dialog-panel' />").appendTo("#popup-layout")
    @back_drop = new BackDropView()
    @back_drop.show()
    @loadTemplate () =>
      @$el = $(@render()).appendTo(@$dialog)
      #$(window).scroll()
    @activity_bind_view = new ActivityBind({el: @$dialog, model: @model})
    super

  loadTemplate: (handle) ->
    $.get @model.url() + ".dialog", (data) =>
      @template = data
      handle.call(@)
      @delegateEvents()

  render: () ->
    @template

  modal: () ->
    $("body").addClass("noScroll")

  unmodal: () ->
    $("body").removeClass("noScroll")

  close: () ->
    @$dialog.remove()
    @back_drop.hide()
    @unmodal()

  playAnimate: () ->
    $body = @$(".main-show")
    animaites = $body.find(".animate0, .animate1, .animate2")
    animaites.each (i, elem) ->
      as = $(elem).attr("class").split(' ')
      class_names = (_(as).filter (e) ->
              _(ANIMATES).contains(e) or /animate\d+/.test(e)).join(' ')

      $(elem).removeClass(class_names)

      setTimeout () ->
        $(elem).addClass(class_names)
      , 100

  load_modal: () ->
    @$dialog.find(".container").slideUp()
    $('#PickCircle').modal({
      remote: "/people/#{ @login}/communities/all_circles",
      keyboard: true,
      backdrop: false
    })

  share_activity: () ->
    return false if $(".share_activity .disabled").length == 1
    @$(".share_activity").addClass('disabled')
    ids = @activity_bind_view.data()
    activity_id = @model.get('id')
    $.ajax(
      data: {ids: ids}
      url: "/activities/"+activity_id+"/share_activity"
      type: "post"
      success: () =>
        pnotify(text: '分享活动成功！!')
        $("#PickCircle").modal('hide')
        @$dialog.find('.container').slideDown()
      error: (messages) ->
        pnotify(text: messages.responseText, type: "error")
    )


class ActivityPreview extends Backbone.View

  events:
    "click .activity .preview"      : "launch"
    "click .activity .launch-button": "buy"
    "click .activity .activity_tag" : "launch"
    "click .activity .like-button"  : "like"
    "click .activity .unlike-button": "unlike"
    "click .activity .follow"       : "follow"
    "click .activity .unfollow"     : "unfollow"

  like_template: '<a href="#" class="btn like-button"><i class="icon-heart"></i>&nbsp;喜欢</a>'
  unlike_template: '<a href="#" class="btn unlike-button active">取消喜欢</a>'

  initialize: (options) ->
    _.extend(@, options)

  launch: (event) ->
    @load_view(event.currentTarget)
    new ActivityView({
      model: @model,
      login: @login
    })
    false

  like: (event) ->
    @load_view(event.currentTarget)
    $.post(@model.url() + "/like", (data) =>
      @$('.like-button').replaceWith(@unlike_template)
      @incLike()
    )
    false

  unlike: (event) ->
    @load_view(event.currentTarget)
    $.post(@model.url() + "/unlike", (data) =>
      @$('.unlike-button').replaceWith(@like_template)
      @decLike()
    )
    false

  incLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s + n)

  decLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s - n)

  load_view: (target) ->
    @$el = @el = $(target).parents(".activity")
    @model = new ActivityModel({ id: @el.attr("activity-id"), shop_id: $(@el).find(".shopinfo").attr("data-value-id") })
    @delegateEvents()

  buy: (event) ->
    @load_view(event.currentTarget)
    new ActivityBuyView({activity_id: @model.id})

  get_model: (event) ->
    @load_view(event.currentTarget)
    @_follow ||= new Follow({follow_type: 'Shop', follow_id: @model.get('shop_id')}, @login)

  follow: (event) ->
    @get_model(event)
    @_follow.follow (model, data) =>
      $(".shopinfo .follow").each (_i, elem) =>
        if $(elem).attr("data-value-id") == @model.get('shop_id')
          $(elem).addClass("unfollow").removeClass("follow")
          $(elem).html("取消关注")

  unfollow: (event) ->
    @get_model(event)
    unless @_follow.has("id")
      id = @$(".unfollow").attr("data-follow-id");
      @_follow.set({id: id})
      
    @_follow.destroy success: (model, data) =>
      $(".shopinfo .unfollow").each (_i, elem) =>
        if $(elem).attr("data-value-id") == @model.get('shop_id')
          $(elem).addClass("follow").removeClass("unfollow")
          $(elem).html("+ 关注")

class ProductViewTemplate extends Backbone.View
  initialize: () ->
    @template = Hogan.compile($("#product-preview-template").html())
    @$el = $(@template.render(@model)) if @template

  render: () ->
    @$el.find(".price").html(@model.price.toString().toMoney()) if @model.price
    @


class ShopProductViewTemplate extends Backbone.View

  initialize: () ->
    @template = Hogan.compile($("#shop-product-preview-template").html())
    @$el = $(@template.render(@model)) if @template

  render: () ->
    @$el.find(".price").html(@model.price.toString().toMoney()) if @model.price
    @


class ActivityViewTemplate extends Backbone.View
  initialize: () ->
    @template = Hogan.compile($("##{@model.activity_type}-preview-template").html())
    @$el = $(@template.render(@model)) if @template

  render: () ->
    @show_status(@get_status())
    @

  show_status: (status) ->
    @$el.find(".price").html(@model.price.toString().toMoney()) if @model.price
    @$el.find(".time-left").html(status.text).addClass(status.name)
    switch status.name
      when 'over'
        $(".buttons>.launch-button", @$el).remove()
      when 'waiting'
        $(".buttons>.launch-button", @$el).remove()

  get_status: () ->
    time_wait = @model.start_time.toDate().getTime() - new Date().getTime()
    return {name: 'waiting', text: "敬请期待"} unless time_wait < 0
    time_left = @model.end_time.toDate().getTime() - new Date().getTime()
    return {name: 'over', text: "已结束"} unless time_left > 0

    leave1 = time_left%(24*3600*1000) # 计算天数后剩余的毫秒数
    leave2 = leave1%(3600*1000)
    # leave3 = leave2%(60*1000)
    days = Math.floor(time_left/(24*3600*1000))
    return {name: 'started', text: "还剩#{days}天"} if days > 0
    hours = Math.floor(leave1/(3600*1000))
    return {name: 'started', text: "仅剩#{hours}小时"} if hours > 0
    minutes = Math.floor(leave2/(60*1000))
    return {name: 'started', text: "最后#{minutes}分钟"} if minutes > 0
    # seconds = Math.round(leave3/1000)


class AskBuyViewTemplate extends Backbone.View
  initialize: () ->
    @template = Hogan.compile($("#ask_buy-preview-template").html())
    @$el = $(@template.render(@model)) if @template

  render: () ->
    $(".notify", @$el).html("已经有商家参与") if @model.status == 1
    @$el.find(".price").html(@model.price.toString().toMoney()) if @model.price
    @


class ActivityModel extends Backbone.Model

  urlRoot: '/activities'


class CycleIter
  constructor: (@data, @pos = 0) ->

  next: () ->
    @pos = 0 unless @pos < @data.length
    @data[@pos++]


class ActivityLayoutView extends Backbone.View
  initialize: (@options) ->
    _.extend(@, @options)

    $(window).bind('search_result:append', $.proxy(@appendResult, @))
    $(window).bind('search_result:reset', $.proxy(@setResult, @))
    $(window).resize($.proxy(@relayoutColumns, @))
    @relayoutColumns()

  resizeWrap: (e) ->
    #@$el.width(@$columns.width())

  appendResult: (e, product) ->
    $columns = @$('.column')
    count = $columns.size()
    view = @generateView(product)
    target = @min_column_el()
    view.$el
      .hide()
      .appendTo(target)
      .fadeIn()

  setResult: (e, data) ->
    @$el.empty()
    @relayoutColumns()
    data = data.data
    if data? and _.isArray(data)
      data.map (product, i) =>
        @appendResult(e, product)

  adjustNumber: () ->
    count = parseInt(@$('.columns').width() / 235)

  relayoutColumns: () ->
    @render_columns()
    activities = @fetchResults()

    columns = $("<div class='columns'></div>")
    columns.append("<div class='column' />") for i in [0...@adjustNumber()]

    cycle = new CycleIter(columns.find(".column"))

    for act in activities
      target = cycle.next()
      $(target).append(act)

    @$(".columns").replaceWith(columns)
    @resizeWrap()

  fetchResults: () ->
    row = 0
    columns = @$(".column")
    results = []

    while _(_(columns).map (elem, i ) ->
      node = $(elem).find(">div")[row]
      results.push(node) if node?
      node).any()
      row++
    results

  generateView: (model, default_type = "product") ->
    switch model._type || default_type
      when "product"
        new ProductViewTemplate(model: model).render()
      when "shop_product"
        new ShopProductViewTemplate(model: model).render()
      when "activity"
        new ActivityViewTemplate({model: model}).render()
      when "ask_buy"
        new AskBuyViewTemplate(model: model).render()
      else
        console.error('没有模板')

  min_column_el: () ->
    columns = @$(".columns>.column")
    cls = _.map columns, (c) -> $(c).height()
    $(columns[cls.indexOf(_.min(cls))])

  render_columns: () ->
    $("<div class='columns'></div>").appendTo(@$el)


class LoadActivities extends InfiniteScrollView
  params: {
    msg_el: ".scroll-load-msg"
    sp_el: "#activities"
    fetch_url: "/search"
  }

  initialize: (options) ->
    super this.params
    $(window).bind "reset_search", (e, data) =>
      @reset_fetch(data)

  add_one: (c) ->
    $(window).trigger("search_result:append", c)

  after_add: () ->
    effect = "fadeInRight"
    $('.activity').hover (event) =>
      $(event.currentTarget)
        .find(".right_bottom2")
        .addClass("animate1 " + effect)
      $(event.currentTarget)
        .find(".right_bottom1")
        .addClass("animate2 " + effect)
        # $(event.currentTarget)
        # .find(".preview")
        # .addClass("animate0 " + "flipInY")

    $('.activity').mouseleave (event) =>
      $(event.currentTarget)
        .find(".right_bottom2")
        .removeClass("animate1 " + effect)
      $(event.currentTarget)
        .find(".right_bottom1")
        .removeClass("animate2 " + effect)
        # $(event.currentTarget)
        # .find(".preview")
        # .removeClass("animate0 " + "flipInY")

class root.LikeListView extends Backbone.View

  item_row:
    '<tr id="liked_activity{{id}}" class="like_main activity" activity-id="{{ id }}">
      <td><img src="{{ url }}" class="activity_icon" ></td>
      <td class="title_td">
        <span class="title" data-toggle="tooltip" title="{{title}}">
          {{title}}
        </span>
      </td>
      <td class="shop"> <a href="/shops/<%= activity.shop.name %>"> {{ shop_name }}</a></td>
      <td><a class="preview" href="javascript:void(0)">查看</a></td>
    </tr>'

  trHtml: (activity) ->
    row_tpl = Hogan.compile(@item_row)
    row_tpl.render(activity)

  add_to_cart: (activity) ->
    $(".like_list").append(@trHtml(activity))
    new ActivityPreview({ el: $("#liked_activity#{ activity.id } ")})

  move_from_cart: (data) ->
    $("#liked_activity#{data.id}").remove()

root.ActivityModel = ActivityModel
root.ActivityPreview = ActivityPreview
root.ActivityView = ActivityView
root.ActivityLayoutView = ActivityLayoutView
root.LoadActivities = LoadActivities
