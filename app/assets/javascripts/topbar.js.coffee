root = (window || @)

class TopBar extends Backbone.View

  events:
    "click .link.friends": "toggleFriends"
    "click .search-btn"  : "enterSearch"
    "submit form"        : "enterSearch"
    "mouseenter .user-avatar" : "show_notify"

  initialize: (@options) ->
    @resultTarget = $(@options['results'] || '#activities')
    $('.link.friends').bind('click', $.proxy(@toggleFriends, @))
    @toggleFriends()

    new TypeaheadExtension({
      el: @$("input.search-query"),
      source: "/search/all",
      highlighter: (item) ->
        if _.include(["ask_buy", "activity"], item._type)
          item.name = item.title

        return item.name

      select: (item)  ->
        return item.name
    })

  toggleFriends: () ->
    $("body").toggleClass("open_right_side")
    # $('.right-sidebar').animate({ width: 'toggle'},callback)
    $(window).trigger('resize')
    false

  enterSearch: (e) ->
    query = @$("[type=search]").val().trim()
    $(window).trigger('reset_search', {title: query})
    false

  show_notify: () ->
    $(".realtime_state").popover('show')

root.TopBar = TopBar