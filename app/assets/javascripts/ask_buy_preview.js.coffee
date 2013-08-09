#= require backbone
#= require lib/hogan

root = (window || @)

class Preview extends Backbone.View
  events: {
    "click .close" : "hide",
    "click .submit-comment" : 'comment',
    "keyup textarea[name='content']" : 'filter_status'
  }
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @template = Hogan.compile(@template)
    @fetch_dialog()

  fetch_dialog: () ->
    $.ajax(
      url: "/ask_buy/#{@asK_buy_id}",
      success: (data) =>
        @render(data)
    )

  render: (data) ->
    @$el.html(@template.render(data))
    @parent_el.html @$el
    @textarea = @$("textarea[name='content']")
    @btn = @$(".submit-comment")

  hide: () ->
    @el.remove()

  comment: () ->
    content = @textarea.val()
    return false if _.isEmpty(content)
    $.ajax(
      url: "/ask_buy/#{@asK_buy_id}/comment",
      type: 'POST',
      data: {comment: {content: content}},
      success: (comment) =>
        @render_comment(comment)
      )

  filter_status: () ->
    content = @textarea.val()
    if _.isEmpty(content)
      @btn.addClass("disabled")
    else
      @btn.removeClass("disabled")

  render_comment: (comment) ->
    comment = Hogan.compile(@comment_template).render(comment)
    @$(".comments").append(comment)


class root.AskBuyPreview extends Backbone.View
  events: {
    "click .in-box" : 'preview'
  }

  initialize: (options) ->
    _.extend(@, options)

  preview: (event) ->
    event_el = $(event.currentTarget.parentElement).parent()
    asK_buy_id = event_el.attr('ask-buy-id')
    new Preview(
      parent_el: @parent_el,
      asK_buy_id: asK_buy_id,
      comment_template: @comment_template,
      template: @preview_template)
