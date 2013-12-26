#= require lib/state-view
#= require lib/kkcountdown
#= require lib/notify

exports = window || @

class Transaction extends Backbone.Model
  set_url: (url) ->
    @urlRoot = url

class TransactionCardBase extends AbstructStateView

  initialize:(@option) ->
    @options['initial'] ?= @current_state().state
    @options['id']        ?= @$el.attr('state-id')
    @options['url']       ?= @$el.attr('state-url')
    @options['event_url'] ?= @$el.attr('state-event-url')
    @options['url_root'] ?= @$el.attr('url-root')
    @options['token']    ?= @$el.data('token')
    @options['number']   ?= @$el.data('number')

    @transaction = new Transaction(
      _.extend({
        id: @options['id'],
        token: @options['token'],
        number: @options['number']
      }, @current_state()))

    @transaction.set_url(@options['url_root'])
    @transaction.bind("change:state", @change_state, @)

    @load_realtime()
    super

  countdown: () ->
    @$(".clock").kkcountdown({
      dayText         : '天',
      daysText        : '天',
      hoursText       : '时',
      minutesText     : '分',
      secondsText     : '秒',
      displayZeroDays : true,
      # callback      : test,
      oneDayClass     : 'one-day'
    })

  clickAction: (event) ->
    btn = $(event.target)
    if !btn.hasClass("disabled")
      event_name = btn.attr('event-name')
      if @[event_name]
        try
          @[event_name].call(@)
        catch error
          @notify("错误信息", error, "error")
      else
        @notify("错误信息", "状态机错误！无权进行此项操作", "error")
    false


  stateChange: (data) ->
    event_name = data.event || "refresh"
    console.log event_name
    @[event_name].call(@)
    $.get @url(), (data) =>
      @effect 'flipInY'

      setTimeout () =>
        # @$el.wrap("<p>")
        # p = @$el.parent()
        # p.html(data)
        # @$el.unwrap()
        html = $(data)
        @$el.replaceWith(html)
        @$el = html
        @delegateEvents()
        @countdown()
        @transaction.set(@current_state())
        # .html(data).unwrap()
      , 300

      # @$el.addClass("animated flipInY")

  closeThis: (event) ->
    if confirm("要取消这笔交易吗?")
      @transaction.fetch({
        url: @transaction.urlRoot,
        type: "DELETE",
        success: (model, data) =>
          $(@el).remove()
      })

  eventUrl: (event) ->
    @options['event_url'] + "/#{event}"

  url: () ->
    @options['url']

  slideBeforeEvent: (event) ->
    @slideEvent(event, 'left')

  slideAfterEvent: (event) ->
    @slideEvent(event, 'right')

  slideEvent: (event, direction = 'right') ->
    $.post @eventUrl(event), (data) =>
        @slidePage(data, direction)
    .fail (data) =>
      if data.status isnt 500
        error_massage = JSON.parse(data.responseText).message
        @notify("错误信息", error_massage, "error")


  slidePage: (page, direction = 'right') ->
    $side1 = $("<div class='slide-1'></div>")
    $side2 = $("<div class='slide-2'></div>")

    @$el.find("iframe").remove()
    @$el.wrap($("<div class='slide-box'></div>"))
    @$el.wrap($("<div class='slide-container'></div>"))
    @$el.wrap($side1)
    $slideBox = @$el.parents(".slide-box")
    $slideContainer = @$el.parents(".slide-container")
    $slideContainer.append($side2)
    $side2.html(page)

    iframe = $side2.find("iframe").remove()
    $side1 = @$el


    height =  Math.max($side2.height(), $side1.height())
    length = $slideBox.width()
    width = @$el.width()

    $slideBox.height(height)
    $slideBox.width(width)
    $slideContainer.width( width * 2)
    $slideContainer.height( height )

    $side1.width(width)
      .height($side1.height())

    overSlide = () =>
      $side1.unwrap()
      .remove()
      @el = @$el = $side2.find(">.transaction")
      @delegateEvents()
      $side2.find(">.transaction")
      .unwrap()
      .unwrap()
      .unwrap()
      @$(".transaction-footer .message_wrap").append(iframe)
      @transaction.set(@current_state())

    if direction == 'right'
      $side1.css('float', 'left')
      $side2.width(width)
      .css('float', 'left')
      $slideBox.animate { scrollLeft: length }, "slow", overSlide
    else
      $side1.css('float', 'right')
      $side2.width(width)
            .css('float', 'left')
      $slideBox.scrollLeft(length)
      $slideBox.animate { scrollLeft: -length }, "slow", overSlide

  effect: (effect_name, handle) ->
    if Modernizr.cssanimations?
      classies = "animated #{effect_name}"
      @$el.addClass(classies)
      setTimeout () =>
        @$el.removeClass(classies)
      , 1300
    else
      handle.call(@) if _(handle).isFunction()

  alarm: () ->
    effect = "bounce"
    @$el.removeClass("animated #{effect}").addClass("animated #{effect}");
    wait = window.setTimeout () =>
      @$el.removeClass("animated #{effect}")
    , 1300

  notify: (title, message, type) ->
    pnotify({
      title: title,
      text: message,
      type: type
    })

  setMessagePanel: () ->
    @message_panel = @$(".message_wrap", ".transaction-footer")
    total = @$(".wrapper-box>>.left").outerHeight()
    tm = @$(".message-toggle").outerHeight()
    wrap = @$('.transaction-footer')
    padding = parseInt(wrap.css("padding-top")) + parseInt(wrap.css("padding-bottom"))
    @message_panel.height(total - tm - padding)

  toggleMessage: () ->
    # @$(".message_wrap", ".transaction-footer").slideToggle()
    unless @model?
      @model = new ChatModel({
        type: 3,
        target_el: @$('.message_wrap'),
        name: @transaction.get('token'),
        title: "订单 #{@transaction.get('number')}"
      })
      @model = ChatListView.getInstance().temporarys_view.addModel(@model)
    @model.icon_view.toggleChat()
    false

  current_state: () ->
    {
      state: @$el.attr('state-initial'),
      state_title: @$el.attr('state-title')
    }

  change_state: () ->
    @setMessagePanel()

  load_realtime: () ->
    @client = window.clients.socket
    @client.subscribe "#{@realtime_url()}/change_state", (data) =>
      @stateChange data

  realtime_url: () ->
    "/#{@transaction.id}"

exports.TransactionCardBase = TransactionCardBase
exports
