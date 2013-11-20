#= require twitter/bootstrap/typeahead

root = (window || @)
class TypeaheadExtension
  limit: 10

  select: (item) ->

  constructor: (options) ->
    $.extend(@, options)
    @$el = $(@el)

    unless _.isArray(@source)
      @url = @source
      @source = $.proxy(@remote, @)

    $(@el).typeahead({
      source: @source,
      matcher: @matcher,
      sorter: @sorter,
      highlighter: $.proxy(@highlighter,@),
      updater: $.proxy(@updater, @)
    })
    @typeh = @$el.data("typeahead")
    @typeh.render = $.proxy(@render, @)

  remote: (query, process) ->
    $.ajax(
      url: @url
      data: {q: query, limit: @limit}
      success: (data) =>
        process(data)
    )

  matcher: (obj) ->
    return 1
  sorter: (items) ->
    return items

  highlighter: (item) ->
   item[@field]

  updater: (value) ->
    item = @typeh.$menu.find('.active').data("value")
    @select(item)
    return item[@field] || item.name

  render: (items)->
    items = $(items).map((i, item) =>
      i = $(@typeh.options.item).data('value', item)
      i.find('a').html(@highlighter(item))
      return i[0]
    )
    items.first().addClass('active')
    @typeh.$menu.html(items)

    return @typeh


root.TypeaheadExtension = (options) ->
  new TypeaheadExtension(options)