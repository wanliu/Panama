
root = window || @

# 抽象出的无限滚动加载视图
class InfiniteScrollView extends Backbone.View
  offset: 0,
  limit: 20,
  init_size: 40,
  msg_tip: '<div class="text-center alert alert-success">亲，已经到底啦～～～</div>'
  search_options: {

  }
  initialize: (options) ->
    _.extend(@, options)
    @$el = $(@el)
    @fetch()
    $(window).scroll(_.bind(@scroll_load, @))

  fetch: () ->
    $(@msg_el).show()
    @fetch_size ||= @init_size
    $.ajax(
      url: @fetch_url,
      dataType: "json",
      data: _.extend({}, {q: @search_options}, offset: @offset,limit: @fetch_size),
      success: (data) =>
        if data.length == 0
          $(@msg_el).html(@msg_tip)
        else if data.length == @fetch_size
          $(@msg_el).hide()
          @add_columns(data)
          @offset += @fetch_size
        else
          @add_columns(data)
          @offset += @fetch_size
          $(@msg_el).html(@msg_tip)
        @fetch_size = @limit
    )

  min_column_el: () ->
    columns = $(@sp_el).find(".columns>.column")
    cls = _.map columns, (c) -> $(c).height()
    $(columns[cls.indexOf(_.min(cls))])

  add_columns: (data) ->
    _.each data, (c) =>
      @add_one(c)
    @after_add()

  add_one: (c) ->

  after_add: () ->

  scroll_load: () ->
    if $(@msg_el).css("display") != "block"
      sp_height = $(@sp_el).offset().top + $(@sp_el).height()
      w_height = $(window).height() + $(window).scrollTop()
      if sp_height <= w_height
        clearTimeout(@timeout_id) if @timeout_id
        @timeout_id = setTimeout _.bind(@fetch, @), 250
  remove_columns: () ->
    $(@sp_el).find(".columns>.column").children().remove()

  reset_fetch: (options) ->
    @search_options = options
    @remove_columns()
    @offset = 0
    @fetch_size = @init_size
    @fetch()


root.InfiniteScrollView = InfiniteScrollView
