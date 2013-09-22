#= require backbone
#= require lib/hogan
root = (window || @)

class Preview extends Backbone.View
  events: {
    "click .close" : "hide",
    "click .submit-comment" : 'comment',
    "keyup textarea[name='content']" : 'filter_status',
    "click [name='join']" : "join"
  }
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @fetch_dialog()

  fetch_dialog: () ->
    $.ajax(
      url: "/ask_buy/#{@ask_buy_id}.dialog",
      success: (data) =>
        @render(data)
    )

  fetch_comment: () ->
    $.ajax(
      url: "/comments"
      data: {targeable_id: @ask_buy_id, targeable_type: "AskBuy"},
      success: (comments) =>
        _.each comments, (comment) =>
          @render_comment(comment)
    )

  render: (template) ->
    @template = template
    @$backdrop = $("<div class='model-popup-backdrop in'></div>").appendTo("body")
    $("body").addClass("noScroll")
    @$el.html(@template)
    $("#popup-layout").html @$el
    @textarea = @$("textarea[name='content']")
    @btn = @$(".submit-comment")
    @fetch_comment()

  hide: () ->
    @$el.remove()
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
        pnotify(text: "参与求购成功,等待用户付款！")
      error: (xhr) ->
        pnotify(text: JSON.parse(xhr.responseText).join(""),type: "error")
    )


class AskBuyPreview extends Backbone.View
  events: {
    "click .ask_buy .preview" : 'preview'
  }

  initialize: (options) ->
    _.extend(@, options)

  preview: (event) ->
    id = $(event.currentTarget).parents(".ask_buy").attr("ask-buy-id")
    new Preview( ask_buy_id: id )


root.AskBuyPreview = AskBuyPreview
