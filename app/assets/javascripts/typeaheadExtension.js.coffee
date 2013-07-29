#= require twitter/bootstrap/typeahead

root = (window || @)
class TypeaheadExtension
  select: (id) ->
  constructor: (options) ->
    $.extend(@, options)
    @$el = $(@el)

    unless _.isArray(@source)
      @url = @source
      @source = $.proxy(@remote, @)

    $.fn.typeahead.Constructor.prototype.render = @render

    $(@el).typeahead({
      source: @source,
      matcher: @matcher,
      sorter: @sorter,
      highlighter: $.proxy(@highlighter,@),
      updater: $.proxy(@updater,@)
    })

  remote: (query, process) ->
    $.ajax(
      url: @url
      data: {q: query}
      success: (data) =>
        process(data)
    )

  matcher:  (obj) ->
    return 1
  sorter: (items) ->
    return items

  highlighter: (item) ->
   item[@field]

  updater: (id) ->
    @select(id)

  render: (items)->
    items = $(items).map((i, item) =>
      i = $(@options.item).attr('data-value', item.id)
      i.find('a').html(@highlighter(item))
      return i[0]
    )
    items.first().addClass('active')
    @$menu.html(items)
    return @


root.TypeaheadExtension = (options) ->
  new TypeaheadExtension(options)