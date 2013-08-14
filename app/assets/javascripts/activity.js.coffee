# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery
#= require backbone
#= require lib/hogan
#= require my_cart
#= require ask_buy_preview

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

  events: {
    "click [data-dismiss=modal]": "close"
    "click .animate-play"     : "playAnimate"
    "click .like-button"    : "like"
    "click .unlike-button"    : "unlike"
    "click .partic-button"    : 'addToCard'
    "click .submit-comment"     : "addComment"
  }

  like_template: '<a class="btn like-button" href="#"><i class="icon-heart"></i> 喜欢</a>'
  unlike_template: '<a class="btn unlike-button active" href="#">取消喜欢</a>'

  initialize: (@options) ->
    _.extend(@, @options)
    backdrop = "<div class='model-popup-backdrop in' />"

    @loadTemplate () =>
      @$backdrop ||= $(backdrop).appendTo("#popup-layout")
      @$el = $(@render()).appendTo(@$backdrop)
      $(window).scroll()
    super

  loadTemplate: (handle) ->
    $.get @model.url() + ".dialog", (data) =>
      @template = data
      handle.call(@)
      @delegateEvents()

  render: () ->
    tpl = Hogan.compile(@template)
    tpl.render(@model.attributes)

  modal: () ->
    # @$el
    #   .addClass("in")
    #   .css('display', 'block')
    #   .css('top', '10%')
    # $(".wrap").addClass("to-blur")
    # $("#sidebar").addClass("to-blur")
    # $(".right-sidebar").addClass("to-blur")
    $("body").addClass("noScroll")

  unmodal: () ->
    # $(".wrap").removeClass("to-blur")
    # $("#sidebar").removeClass("to-blur")
    # $(".right-sidebar").removeClass("to-blur")
    $("body").removeClass("noScroll")

  # events

  addToCard: (e) ->
    $target = $(e.currentTarget)
    [ $form, url ] = [ @$('.new_product_item'), $target.attr('add-to-action')]
    MyCart.myCart.addToCart(@$('.preview'),$form , url)
    false

  close: () ->
    @$backdrop.remove()
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
    @model.url()
    $.post(@model.url() + "/like")
    @$('.like-button').replaceWith(@unlike_template)
    @$('.like-count').addClass("active")
    @incLike()
    false

  unlike: (event) ->
    @model.url()
    $.post(@model.url() + "/unlike")
    @$('.unlike-button').replaceWith(@like_template)
    @$('.like-count').removeClass("active")
    @decLike()
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
    $.post('/comments/activity', {comment: comment})
    comment_template = _.template($('#comment-template').html())
    @$(".comments").append(comment_template(comment))
    @$(".comments>.comment").last().slideDown("slow")
    @$("textarea",".message").val("")


class ActivityPreview extends Backbone.View

  events:
    "click .preview"    : "launchActivity"
    "click .like-button"  : "like"
    "click .unlike-button"  : "unlike"
    "click .launch-button"  : "launchActivity"


  like_template: '<a href="#" class="btn like-button"><i class="icon-heart"></i>&nbsp;喜欢</a>'
  unlike_template: '<a href="#" class="btn unlike-button active">取消喜欢</a>'

  launchActivity: (event) ->
    @model.fetch success: (model) =>
      view = new ActivityView({
        el       : @$el,
        model    : @model })
      view.modal()
    false

  like: (event) ->
    @model.url()
    $.post(@model.url() + "/like")
    @$('.like-button').replaceWith(@unlike_template)
    @incLike()
    false

  unlike: (event) ->
    @model.url()
    $.post(@model.url() + "/unlike")
    @$('.unlike-button').replaceWith(@like_template)
    @decLike()
    false

  incLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s + n)

  decLike: (n = 1) ->
    s = parseInt(@$('.like-count').text()) || 0
    @$('.like-count').text(s - n)


class ProductPreview extends Backbone.View

  render: () ->
    @template = @options? and @options['template']
    @$el = $(@template.render(@model)) if @template
    @

class ActivityModel extends Backbone.Model

  urlRoot: '/activities'

class CycleIter
  constructor: (@data, @pos = 0) ->

  next: () ->
    @pos = 0 unless @pos < @data.length
    @data[@pos++]

class ActivitiesView extends Backbone.View

  COLUMN_WIDTH = 233

  initialize: (@options) ->

    $(window).bind('search_result:append', $.proxy(@appendResult, @))
    $(window).bind('search_result:reset', $.proxy(@setResult, @))
    $(window).resize($.proxy(@relayoutColumns, @))
    @relayoutColumns()

  resizeWrap: (e) ->
    @$el.width(@adjustNumber() * 246)

  appendResult: (e, data) ->

    $columns = @$('.column')
    count = $columns.size()
    data = data.data

    if data? and _.isArray(data)
      data.map (product, i) =>
        view = @generateView(product)
        target = $($columns[i % count])
        view.$el
          .hide()
          .appendTo(target)
          .fadeIn()

  setResult: (e, data) ->
    @$el.empty()
    @relayoutColumns()
    @appendResult(e, data)

  adjustNumber: () ->
    $wrap = $('.wrap')
    count = parseInt(($wrap.width() - 25) / 246)

  relayoutColumns: () ->

    activities = @fetchResults()
    new_dom = $("<div id='activities'/>")
    new_dom.append("<div class='column' />") for i in [0...@adjustNumber()]

    cycle = new CycleIter(new_dom.find(".column"))

    for act in activities
      target = cycle.next()
      $(target).append(act)

    @$el.replaceWith(new_dom)
    @$el = new_dom
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
    @pdPreview ||= Hogan.compile($("#product-preview-template").text())
    switch model.type || default_type
      when "product"
        new ProductPreview(model: model, template: @pdPreview).render()
      else
        new ProductPreview(model: model, template: @pdPreview).render()



root.ActivityModel = ActivityModel
root.ActivityPreview = ActivityPreview
root.ActivityView = ActivityView
root.ActivitiesView = ActivitiesView


