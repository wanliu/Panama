
class window.ProductCommentReply extends Backbone.View
  events: {
    "keyup form.reply textarea"    : "filter_status"
    "submit form.reply" : 'reply'
  }

  initialize: () ->
    @raty_url = @options.raty_url
    @reply_url = @options.reply_url
    @stars = @$(".star_panel .star")
    @textarea = @$("textarea")
    @submit = @$("input:submit")
    @$form = @$("form.reply")
    @init_star()

  get_data: () ->
    items = @$form.serializeArray()
    data = {}
    _.each items, (d) ->
      data[d.name] = d.value

    data

  reply: () ->
    items = @get_data()
    product_comment_id = items.product_comment_id
    return false if _.isEmpty(items.content) || _.isEmpty(product_comment_id)
    delete(items.product_comment_id)
    $.ajax(
      type: "post",
      data: items,
      url: "#{@reply_url}/#{product_comment_id}/reply"
      success: (reply) =>
        @$(".create_reply").html("<div class='span2'><img src='#{reply.user_icon_url}' />#{reply.user_login}</div>
          <div class='span10'>#{reply.content}</div>")
    )
    return false


  init_star: () ->
    _.each @stars, (star_el) =>
      el = $(star_el)
      el.raty({
        readOnly : el.attr("star-ready") == "true",
        score    : el.attr("star-value"),
        scoreName: el.attr('star-name'),
        path     : @raty_url
      })

  filter_status: () ->
    value = @textarea.val().trim()
    if _.isEmpty(value)
      @submit.addClass("disabled")
    else
      @submit.removeClass("disabled")