#= require lib/state-view
#= require lib/kkcountdown
#= require lib/notify

exports = window || @

class Transaction extends Backbone.Model
  set_url: (url) ->
    @urlRoot = url

class TransactionCardBase extends AbstructStateView
  dialogState: true

  initialize:(@option) ->
    _.extend(@, @options)
    @options['initial'] ?= @current_state().state
    @options['id']        ?= @$el.attr('state-id')
    @options['url']       ?= @$el.attr('state-url')
    @options['event_url'] ?= @$el.attr('state-event-url')
    @options['url_root'] ?= @$el.attr('url-root')
    @options['token']    ?= @$el.attr('data-token')
    @options['group']   ?= @$el.parents('.wrapper-box').attr('data-group')

    @transaction = new Transaction(
      _.extend({
        id: @options['id'],
        token: @options['token'],
        group: @options['group']
      }, @current_state()))

    @transaction.set_url(@options['url_root'])
    @transaction.bind("change:state", @change_state, @)
    @transaction.bind("change:stotal", @change_stotal, @)

    @load_realtime()
    @generateChat() if @dialogState
    @setChatPanel()
    $(window).bind("resizeOrderChatDialog", _.bind(@setChatPanel, @))
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
    unless btn.hasClass("disabled")
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
      @slidePage(data)
      #@effect 'flipInY'
      ###
      setTimeout () =>
        html = $(data)
        @$el.replaceWith(html)
        @$el = html
        @delegateEvents()
        @countdown()
        @transaction.set(@current_state())
      , 300
      ###


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
    $btn = @$(".transaction-actions .btn_event")
    $btn.addClass("disabled")
    $.post @eventUrl(event), (data) =>
        @slidePage(data, direction)
    .fail (data) =>
      if data.status isnt 500
        error_massage = JSON.parse(data.responseText)
        @notify("错误信息", error_massage, "error")
      @back_state()

    .complete () ->
      $btn.removeClass("disabled")

  slidePage: (page, direction = 'right') ->
    $side1 = $("<div class='slide-1'></div>")
    $side2 = $("<div class='slide-2'></div>")

    @$el.wrap($("<div class='slide-box'></div>"))
    @$el.wrap($("<div class='slide-container'></div>"))
    @$el.wrap($side1)
    $slideBox = @$el.parents(".slide-box")
    $slideContainer = @$el.parents(".slide-container")
    $slideContainer.append($side2)
    $side2.html(page)

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
    message = message.join("<br />") if _.isArray(message)
    pnotify({
      title: title,
      text: message,
      type: type
    })

  setChatPanel: () ->
    $order_row = @$el.parents('.wrapper-box')
    $chat_foot = $order_row.find(".message_wrap .foot")
    $chat_body = $order_row.find(".message_wrap .body")
    setInterval () =>
    $chat_body.height($order_row.outerHeight() - $chat_foot.outerHeight())

  generateChat: () ->
    @generateToken () =>
      @newAttachChat()

  newAttachChat: () ->
    unless @chat_model?
      @chat_model = new ChatModel({
        type: 3,
        name: @transaction.get('token'),
        group: @transaction.get('group')
      })
      @chat_model = ChatManager.getInstance().addChatIcon(@chat_model)
    @chat_model.icon_view.toggleChat()
    false

  generateToken: (handle) ->
    return handle.call(@) unless _.isEmpty(@$el.attr('data-token'))
    $.ajax(
      type: 'POST',
      dataType: 'json',
      url: "#{@transaction.urlRoot}/generate_token",
      success: (data, xhr, res) =>
        @$el.attr('data-token', data.token)
        handle.call(@)
      error: () =>
        pnotify(type: 'error', text: '获取聊天token失败')
    )

  current_state: () ->
    {
      state: @$el.attr('state-initial'),
      state_title: @$el.attr('state-title')
    }

  change_state: () ->
    @setChatPanel()

  load_realtime: () ->
    @client = window.clients

    @client.monitor "#{@realtime_url()}/change_state", (data) =>
      @stateChange data

    @client.monitor "#{@realtime_url()}/change_info", (data) =>
      @transaction.set(data.info)

  realtime_url: () ->
    "/#{@transaction.id}"

  back_state: () ->
    @alarm()
    @transition.cancel()

  change_stotal: () ->
    @replace_total(@$(".stotal"), @transaction.get('stotal'))

  replace_total: (elem, stotal) ->
    if elem.length > 0
      tag = elem.text().trim().substring(0, 1)
      elem.html("#{tag} #{stotal}")



exports.TransactionCardBase = TransactionCardBase
exports
