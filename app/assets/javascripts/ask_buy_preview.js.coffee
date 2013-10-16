#= require backbone
#= require lib/hogan
root = (window || @)

class AskBuyView extends Backbone.View
  events:
    "click .close"                  : "hide"
    "click .submit-comment"         : 'comment'
    "keyup textarea[name='content']": 'filter_status'
    "click [name='join']"           : "join"

  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @loadTemplate()

  loadTemplate: () ->
    @$backdrop = $("<div class='model-popup-backdrop in' />").appendTo("body")
    @$dialog = $("<div class='dialog-panel' />").appendTo("#popup-layout")
    @fetch_dialog () =>
      @$el = $(@render()).appendTo(@$dialog)
      # $(window).scroll()
      @textarea = @$("textarea[name='content']")
      @btn = @$(".submit-comment")
      @fetch_comment()
    #super

  fetch_dialog: (handle) ->
    $.ajax(
      url: "/ask_buy/#{@ask_buy_id}.dialog",
      success: (data) =>
        @template = data
        handle.call(@)
        @delegateEvents()
    )

  fetch_comment: () ->
    $.ajax(
      url: "/comments"
      data: {targeable_id: @ask_buy_id, targeable_type: "AskBuy"},
      success: (comments) =>
        _.each comments, (comment) =>
          @render_comment(comment)
    )

  render: () ->
    @template

  hide: () ->
    @$dialog.remove()
    @$backdrop.remove()
    $("body").removeClass("noScroll")

  comment: () ->
    content = @textarea.val()
    return false if _.isEmpty(content)
    $.ajax(
      url: "/ask_buy/#{@ask_buy_id}/comment",
      type: 'POST',
      data: {comment: {content: content}},
      success: (comment) =>
        @textarea.val('')
        @render_comment(comment)
      )

  filter_status: () ->
    content = @textarea.val()
    if _.isEmpty(content)
      @btn.addClass("disabled")
    else
      @btn.removeClass("disabled")

  render_comment: (comment) ->
    comment = Hogan.compile($("#ask_buy-comment-template").html()).render(comment)
    @$(".comments").append(comment)

  join: () ->
    $.ajax(
      url: "/ask_buy/#{@ask_buy_id}/join",
      type: "POST",
      success: () ->
        pnotify(text: "参与求购成功，等待用户付款！")
      error: (xhr) ->
        pnotify(text: JSON.parse(xhr.responseText).join(""),type: "error")
    )


class AskBuyPreview extends Backbone.View
  events:
    "click .ask_buy .preview" : 'launch'

  initialize: (options) ->
    _.extend(@, options)

  launch: (event) ->
    id = $(event.currentTarget).parents(".ask_buy").attr("ask-buy-id")
    new AskBuyView( ask_buy_id: id )


root.AskBuyPreview = AskBuyPreview
