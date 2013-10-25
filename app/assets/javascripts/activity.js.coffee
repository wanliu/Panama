# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require ask_buy_preview
#= require product_preview
#= require shop_products
#= require lib/infinite_scroll
#= require_tree ./activities
#= require activity_buy

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
    "click .like-button"            : "like"
    "click .unlike-button"          : "unlike"
    "click .auction .partic-button" : 'addToCard'
    "click .submit-comment"         : "addComment"
    "keyup textarea[name=message]"  : 'filter_state'
    'submit form.new_product_item'  : 'join'
    "click .focus .partic-button"   : "joinFocus"
    "click .focus .unpartic-button" : "unjoinFocus"

  like_template: '<a class="btn like-button" href="#"><i class="icon-heart"></i> 喜欢</a>'
  unlike_template: '<a class="btn unlike-button active" href="#"> 取消喜欢</a>'
  unpartic_template: '<button class="btn btn-danger unpartic-button" type="submit" name="unjoin">
                     取消参与
                  </button>'
  partic_template: '<button class="btn btn-danger partic-button active" type="submit" name="join">
                    <i class="icon-shopping-cart icon-white"></i> 参与
                  </button>'

  initialize: (@options) ->
    _.extend(@, @options)

    @$dialog = $("<div class='dialog-panel' />").appendTo("#popup-layout")
    @back_drop = new BackDropView()
    @back_drop.show()
    @loadTemplate () =>
      @$el = $(@render()).appendTo(@$dialog)
      #$(window).scroll()
    super

  loadTemplate: (handle) ->
    $.get @model.url() + ".dialog", (data) =>
      @template = data
      handle.call(@)
      @delegateEvents()

  joinFocus: (event) ->
    $.post($("form", @el).attr("action"), (data) =>
      @$('.partic-button').replaceWith(@unpartic_template)
      @$('.like-count').addClass("active")
      pnotify({text: "成功参与聚焦活动！"})
      @incPartic()
      false
    )
    false

  unjoinFocus: (event) ->
    $.post($("form", @el).attr("action"), (data) =>
      @$('.unpartic-button').replaceWith(@partic_template)
      @$('.partic-count').removeClass("active")
      pnotify({text: "成功取消参与聚焦活动！"})
      @decPartic()
      false
    )
    false

  incPartic: (n = 1) ->
    s = parseInt(@$('.partic-count').text()) || 0
    @$('.partic-count').text(s + n)

  decPartic: (n = 1) ->
    s = parseInt(@$('.partic-count').text()) || 0
    @$('.partic-count').text(s - n)

  render: () ->
    @template

  modal: () ->
    $("body").addClass("noScroll")

  unmodal: () ->
    $("body").removeClass("noScroll")

  addToCard: (e) ->
    $target = $(e.currentTarget)
    [ $form, url ] = [ @$('.new_product_item'), $target.attr('add-to-action')]
    MyCart.myCart.addToCart(@$('.preview'),$form , url)
    false

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

  like: (event) ->
    $.post(@model.url() + "/like", (data) =>
      @$('.like-button').replaceWith(@unlike_template)
      @$('.like-count').addClass("active")
      @incLike()
    )
    false

  unlike: (event) ->
    $.post(@model.url() + "/unlike", (data) =>
      @$('.unlike-button').replaceWith(@like_template)
      @$('.like-count').removeClass("active")
      @decLike()
    )
    false

  incLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s + n)

  decLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s - n)

  addComment: (event) ->
    content = @$("textarea",".message").val()
    return unless content.trim() != ""
    comment = {content: content, targeable_id: @model.id}
    $.ajax(
      url: '/comments/activity',
      data: {comment: comment}
      type: 'POST'
      dataType: "JSON"
      success: (data) =>
        comment_template = _.template($('#comment-template').html())
        @$(".comments").append(comment_template(comment))
        @$(".comments>.comment").last().slideDown("slow")
        @$("textarea",".message").val("")
    )

  filter_state: () ->
    message = @$("textarea",".message").val().trim()
    comment = @$(".submit-comment")
    if _.isEmpty(message)
      comment.addClass("disabled")
    else
      comment.removeClass("disabled")

  join: () ->
    new ActivityBuyView({activity_id: @model.id})

    false

  validate_date: () ->
    values = @$("form.new_product_item").serializeArray()
    data = {}
    _.each values, (v) -> data[v.name] = v.value

    if parseFloat(data['product_item[amount]']) <= 0
      pnotify({text: "数量不能少于等于0"})
      return false

    unless /^\d+(\.?\d+)?$/.test(data['product_item[amount]'])
      pnotify({text: "请输入正确的数量！"})
      return false

    return data

class ActivityPreview extends Backbone.View

  events:
    "click .activity .preview"      : "launch"
    "click .activity .launch-button": "buy"
    "click .activity .activity_tag" : "launch"
    "click .activity .like-button"  : "like"
    "click .activity .unlike-button": "unlike"

  like_template: '<a href="#" class="btn like-button"><i class="icon-heart"></i>&nbsp;喜欢</a>'
  unlike_template: '<a href="#" class="btn unlike-button active">取消喜欢</a>'

  initialize: (options) ->
    _.extend(@, options)

  launch: (event) ->
    @load_view(event.currentTarget)
    new ActivityView({
      model: @model
    }).modal()
    false

  like: (event) ->
    @load_view(event.currentTarget)
    $.post(@model.url() + "/like", (data) =>
      @$('.like-button').replaceWith(@unlike_template)
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
    @model = new ActivityModel({ id: @el.attr("activity-id") })
    @delegateEvents()

  buy: (event) ->
    @load_view(event.currentTarget)
    new ActivityBuyView({activity_id: @model.id})

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
    time_wait = Date.parse(@model.start_time) - new Date()
    return {name: 'waiting', text: "敬请期待"} unless time_wait < 0
    time_left =  Date.parse(@model.end_time) - new Date()
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


class ActivitiesView extends Backbone.View
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
  msg_el: ".scroll-load-msg",
  sp_el: "#activities",
  fetch_url: "/search"

  initialize: (options) ->
    super options
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


root.ActivityModel = ActivityModel
root.ActivityPreview = ActivityPreview
root.ActivityView = ActivityView
root.ActivitiesView = ActivitiesView
root.LoadActivities = LoadActivities
