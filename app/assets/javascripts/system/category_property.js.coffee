
root = window || @

class ChoseProperty

  constructor: (options) ->
    $.extend(@, options)
    @load_elem()
    @bind_events()

  load_elem: () ->
    @chose_all = @$(".chose-all input:checkbox")
    @cbs = @$("tbody input:checkbox")

  bind_events: () ->
    @chose_all.bind "click", $.proxy(@check_all, @)

  check_all: () ->
    state = @chose_all[0].checked
    $.each @cbs, (i, el) -> el.checked = state; true

  $: (selector) ->
    $(selector, @el)

  checked_values: () ->
    values = []
    $.each @cbs, (i, el) -> values.push(el.value) if el.checked
    values

class root.CategoryProperty

  constructor: (options) ->

    @params = {}
    $.extend(true, @, options)

    @chose = new ChoseProperty(
      el: @$("table")
    )
    @bind_events()

  bind_events: () ->
    @$(".join_filter").bind "submit", $.proxy(@join_filter, @)

  join_filter: () ->
    $.ajax(
      url: "/system/categories/#{@params.category_id}/batch_property_values",
      type: "POST",
      data: {property_ids: @chose.checked_values()}
      success: () ->
        pnotify(text: '加入成功', title: '成功信息')
    )
    false

  $: (selector) ->
    $(selector, @el)


