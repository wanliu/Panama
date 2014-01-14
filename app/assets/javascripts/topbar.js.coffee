root = (window || @)

class TopBar extends Backbone.View

  events:
    "click .link.friends": "toggleFriends"
    "click .search-btn"  : "enterSearch"
    "submit form"        : "enterSearch"
    "mouseenter .user-avatar" : "show_notify"
    "click .chose_condition .dropdown-menu>li" : "chose_search_type"

  initialize: (@options) ->
    @resultTarget = $(@options['results'] || '#activities')
    $('.link.friends').bind('click', $.proxy(@toggleFriends, @))
    @toggleFriends()
    @$form = @$("form#search-form")

    @typeahead = new TypeaheadExtension({
      el: @$("input.search-query"),
      source: "/search/all?#{}",      
      highlighter: (item) ->
        if _.include(["ask_buy", "activity"], item._type)
          item.name = item.title
        else if item._type == "user"
          item.name = item.login
        
        return item.name

      select: (item)  =>
        @enterSearch()
    })

    old_show = @typeahead.typeh.show
    @typeahead.typeh.show = () ->
      old_show.call(@)
      @$menu.css(left: 0)
      @

    that = @
    old_render = @typeahead.render    
    @typeahead.typeh.render = (items) ->
      search_type = that.$form.serializeHash().search_type
      switch search_type      
        when "user"
          that.user_render(items)
        when "shop"
          that.shop_render(items)
        when "circle"
          that.circle_render(items)
        else
          old_render.call(that.typeahead, items)

      that.typeahead.typeh

  toggleFriends: () ->
    $("body").toggleClass("open_right_side")
    # $('.right-sidebar').animate({ width: 'toggle'},callback)
    $(window).trigger('resize')
    false

  enterSearch: () ->
    query = @$("[type=search]").val().trim()
    $(window).trigger('reset_search', {title: query})
    false

  show_notify: () ->
    $(".realtime_state").popover('show')

  chose_search_type: (event) ->
    target = $(event.currentTarget)
    value = target.attr("data-value")
    @$("input[name='search_type']").val(value)
    @$(".chose_condition .title").html($("a", target).html())
    @$(".chose_condition>.dropdown").removeClass("open")
    data = @typeahead.data
    @typeahead.data = _.extend(data, @$form.serializeHash())

  user_render: (items) ->
    $menu = @typeahead.typeh.$menu
    $menu.html('')
    _.each items, (item) =>
      $menu.append("""
        <li>
          <a class='user'>
            <img class='icon' src='#{item.photos.icon}' alt='#{item.login}' />
            <span class='login'>#{item.login}</span>
          </a>
        </li>
      """)

  circle_render: (items) ->

  shop_render: (items) ->


root.TopBar = TopBar