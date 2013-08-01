
class window.ProductCommentView extends Backbone.View
  events: {
    "submit form" : "create",
    "keyup textarea" : "filter_content"
  }

  initialize: (options) ->
    _.extend(@, options)
    @$form = @$("form")
    @textarea = @$("textarea")
    @submit = @$("input:submit")
    @star_panel = @$(".star_panel")
    @comments = @$(".comments")
    @stars = @star_panel.find(".star")
    @create_comment = @$(".create_comment")
    @init_star()

  create: () ->
    data = @get_data()
    return false if _.isEmpty(data.content)
    $.ajax({
      url: @create_url,
      type: "POST",
      data: {product_comment: data},
      success: (comment) =>
        @comments.html("<div class='row-fluid'>
          <div class='span2'><img src='#{comment.user_icon_url}' />#{comment.user_login}</div>
          <div class='span10'>#{comment.content}</div>
        </div>")
        @init_star_el(data);
    })
    false

  init_star_el: (data) ->
    _.each @stars, (el) =>
      $(el).attr('star-value', data[$(el).attr('star-name')])
      $(el).attr("star-ready", "true")

    @init_star()

  get_data: () ->
    items = @$form.serializeArray()
    data = {}
    _.each items, (d) ->
      data[d.name] = d.value

    data

  filter_content: () ->
    value = @textarea.val().trim()
    if _.isEmpty(value)
      @submit.addClass("disabled")
    else
      @submit.removeClass("disabled")

  init_star: () ->
    _.each @stars, (star_el) =>
      el = $(star_el)
      el.raty({
        readOnly : el.attr("star-ready") == "true",
        score    : el.attr("star-value"),
        scoreName: el.attr('star-name'),
        path     : @raty_url
      })