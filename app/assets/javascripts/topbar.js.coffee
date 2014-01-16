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
      source: "/search/all",      
      highlighter: (item) =>
        @get_value(item)

      select: (item)  =>
        @enterSearch()
    })

    old_show = @typeahead.typeh.show
    @typeahead.typeh.show = () ->
      old_show.call(@)
      @$menu.css(left: 0)
      @

    old_render = @typeahead.render    
    @typeahead.typeh.render = (items) =>
      search_type = @$form.serializeHash().search_type
      switch search_type      
        when "users"
          @user_render(items)
        when "shops"
          @shop_render(items)
        when "circles"
          @circle_render(items)
        else
          old_render.call(@typeahead, items)

      @typeahead.typeh

    @typeahead.typeh.updater = (value) =>
      $menu = @typeahead.typeh.$menu
      item = $menu.find('.active').data("value")
      value = @get_value(item)
      @typeahead.$el.val(value)
      @typeahead.select(item)
      value

  toggleFriends: () ->
    $("body").toggleClass("open_right_side")
    # $('.right-sidebar').animate({ width: 'toggle'},callback)
    $(window).trigger('resize')
    false

  enterSearch: () ->
    query = @$("[type=search]").val().trim()
    data = @$form.serializeHash()    
    $(window).trigger('reset_search', data)
    false

  show_notify: () ->
    $(".realtime_state").popover('show')

  chose_search_type: (event) ->
    target = $(event.currentTarget)
    value = target.attr("data-value")
    @$("input[name='search_type']").val(value)
    @$(".chose_condition .title").html($("a", target).html())
    @$(".chose_condition>.dropdown").removeClass("open")
    item = @$form.serializeHash()
    @typeahead.data ||= {}
    @typeahead.data["search_type"] = item.search_type

  user_render: (items) ->
    @render_template items, (item) ->
      """
        <li class='user'>
          <a>
            <img class='icon' src='#{item.photos.icon}' alt='#{item.login}' />
            <span class='login'>#{item.login}</span>
          </a>
        </li>
      """

  circle_render: (items) ->
    @render_template items, (item) ->
      """
        <li class='circle'>
          <a>
            <img class='icon' src='#{item.photos.icon}' alt='#{item.name}' />
            <span class='name'>#{item.name}</span>
          </a>
        </li>
      """

  shop_render: (items) ->
    @render_template items, (item) ->
      """
        <li class='shop'>
          <a>
            <img class='icon' src='#{item.photos.icon}' alt='#{item.name}' />
            <span class='name'>#{item.name}</span>
          </a>
        </li>
      """

  render_template: (items, callback = () ->) ->
    $menu = @typeahead.typeh.$menu
    $menu.html('')
    _.each items, (item) =>
      li = $(callback(item)).appendTo($menu)
      li.data("value", item)

    $("li:eq(0)", $menu).addClass("active")

  get_value: (item) ->
    if _.include(["ask_buy", "activity"], item._type)
      return item.title
    else if item._type == "user"
      return item.login
    
    return item.name


root.TopBar = TopBar