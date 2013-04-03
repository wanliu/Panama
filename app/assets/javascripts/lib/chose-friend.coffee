#describe: 选择圈子与范围
((factory) ->
  if typeof define is 'function' && define.amd
    define ['jquery'], factory
  else
    factory(jQuery)
)(
  ($) ->
    class ChoseDropDown
      el: $("<div class='chose-drop-down' />")
      ul_el: $("<ul class='chose-friend-menu' />")
      match: /\{\{(\w{1,})\}\}/i
      status: true
      complete: (data) ->

      constructor: (opts) ->
        $.extend(@, opts)
        @el.append(@ul_el)

      render: () ->
        @el

      show: () ->
        if @el.css("display") is "none"
          @el.show()
          @el.trigger("hide")

      hide: () ->
        @el.hide()

      fetch: (callback) ->
        @complete = callback if $.isFunction(callback)
        if $.isArray(@data)
          @all_data(@data)
        else if typeof @data == "string"
          @remote()

      remote: () ->
        $.get(@data,{} ,$.proxy(@all_data, @), "json")

      all_data: (data) ->
        $.each data, (i, val) =>
          @add_one(val)

        @complete(data)

      add_one: (val) ->
        index = @ul_el.find("li").length
        li = $("<li class='chose-item' index=#{index} />")
        @ul_el.append(li)
        _template = @template
        attr = @match.exec _template
        while attr? && attr.length > 0
          value = val[attr[1]]
          _template = _template.replace @match, value
          attr = @match.exec _template

        $.data li[0], "data", _.extend(val, {_status: "circle"})
        li.html(_template)

    class ChoseInput
      ul_el: $("<ul class='user-shop-list' />")
      li_el: $("<li />")
      el: $("<div class='user-shop-panel' />")

      constructor: (options) ->
        _.extend(@, options)
        @events()
        @el.html(@ul_el)
        @results = {}

      events: () ->
        @input.bind "keyup", () =>
          clearTimeout(@time_id) if @time_id?
          @time_id = setTimeout(_.bind(@fetch_user_shop, @), 300)

      fetch_user_shop: () ->
        search_val = @input.val().trim()
        if search_val isnt ""
          if @results.hasOwnProperty(search_val)
            @all_result @get_result(search_val)
          else
            $.get "/search/users", {search_val: search_val, limit: 15}, (data) =>
              @all_result(data)
              @cap_result search_val, data
        else
          @hide()

      cap_result: (key, data) ->
        @results[key] = data

      get_result: (key) ->
        @results[key]

      render: () ->
        @el

      all_result: (data) ->
        @show()
        @ul_el.html("")
        _.each data, (model) =>
          @add_user model

      add_user: (model) ->
        unless @find_user_id(model.id)
          li = @add_el(model.icon, model.login)
          @set_data(li[0], _.extend({}, model, {_status: "user", value: model.login}))

      set_data: (li, data) ->
        $.data li, "data", data

      add_el: (url, name) ->
        li = @li_el.clone()
        panel = @create_panel()
        panel.append(@create_avatar_el(url))
        panel.append(@create_name_el(name))
        li.append(panel)
        @ul_el.append(li)
        li

      hide: () ->
        @el.hide()
        @el.trigger("show")

      show: () ->
        @el.show()
        @el.trigger("hide")

      create_panel: () ->
        $("<a />")

      create_name_el: (name) ->
        $("<span class='name'>#{name}</span>")

      create_avatar_el: (url) ->
        $("<img class='img-polaroid' src='#{url}' />")

      is_show: () ->
        @el.css("display") == "block"

      find_user_id: (user_id) ->
        data = @selector_data()
        for d in data
          if d.value._status == "user" && d.value.id == user_id
            return true

        return false

    class ChoseFriend
      options: { }

      constructor: (opts) ->
        @set_options(opts)
        @create_element()

        @drop_down = new ChoseDropDown(
          value: @options["value"],
          data : @options["data"],
          template: @options["template"]
        )

        @drop_down.ul_el.append(@options.init_template)
        @drop_down.fetch($.proxy(@load_default_value, @))

        @chose_view = new ChoseInput(
          input: @options.input,
          selector_data: _.bind(@selector_data, @)
        )

        @chose_view.el.bind("hide", _.bind(@drop_down.hide, @drop_down))
        @chose_view.el.bind("show", _.bind(@drop_down.show, @drop_down))
        @drop_down.el.bind("hide", _.bind(@chose_view.hide, @chose_view))

        @options.el.append(@chose_view.render())
        @options.el.append(@drop_down.render())

        @load_css()
        @events()

      selector_data: () ->
        items = @selector_panel.find(".chose-label")
        data = []
        $.each items, (i, item) =>
          data.push(@get_data item)
        data

      set_options: (opts) ->
        $.extend(@options, @defulat_opts, opts)

      load_css: () ->
        @options.el.addClass("chose-friend")

      events: () ->
        @input_panel.bind "click", () =>
          @options.input.focus()
          event.stopPropagation()

        @options.input.focus () =>
          unless @chose_view.is_show()
            @drop_down.show()

          event.stopPropagation()

        $(window).click () =>
          @chose_view.input.val("")
          @chose_view.hide()
          @drop_down.hide()

        @drop_down.ul_el.on "click", "li", (event) =>
          data = @get_data event.currentTarget
          @selector_drop(data, $(event.currentTarget))
          event.stopPropagation()

        @chose_view.ul_el.on "click", "li", (event) =>
          data = @get_data event.currentTarget
          @selector_user(data, $(event.currentTarget))
          @chose_view.input.val("")
          @chose_view.hide()
          event.stopPropagation()

        @selector_panel.on "click", ".close-label", (event) =>
          @close_item(event)
          event.stopPropagation()

        @drop_down.ul_el.on "mouseover", "li[data-toggle=popover]", (event) =>
          li = $(event.currentTarget)
          li.popover( content: li.attr("data-content") ).popover("show")

        @drop_down.ul_el.on "mouseout", "li[data-toggle=popover]", (event) =>
          $(event.currentTarget).popover("hide")

      close_item: (event) ->
        parent_el = event.currentTarget.parentElement
        data = @get_data(parent_el)
        status = data.value._status
        if data.html? && status isnt "shop" && status isnt "user"
          @show_item(data) if data?
          @options.close_item(data, parent_el)

        $(parent_el).remove()

      show_item: (data) ->
        li = data.html[0]
        @drop_down.ul_el.append(li)
        @set_data(li, data.value)
        @sort_item()

      sort_item: () ->
        $("li", @drop_down.ul_el).each (i, bli) =>
          $("li", @drop_down.ul_el).each (j, ali) ->
            bindex = parseInt($(bli).attr("index"))
            aindex = parseInt($(ali).attr("index"))
            if bindex > aindex
              $(bli).before($(ali))

      load_default_value: (_data) ->
        if @options.default_value? && @options.default_value != ""

          $("li", @drop_down.ul_el).each (i, li) =>
            data = @get_data(li)
            unless data?
              data = $(li).attr("data-value")
              @set_data(li, data)
            @default_value(data, li)

      default_value: (data, li) ->
        if data?
          if (@options.value? && @options.value != "" &&
          data[@options.value] == @options.default_value) ||
          data == @options.default_value
            $(li).click()
            @drop_down.hide()
            @options.input.blur()

      set_data: (li, data) ->
        $.data li, "data", data

      get_data: (li) ->
        $.data(li, "data")

      selector_drop: (data, li) ->
        label = @options.chose_circle_label.clone()
        label = @_selector(data, li, label)
        label.html(li.remove().find("a").html())
        label.append(@options.close_label.clone())

      selector_user: (data, li) ->
        user_el = @create_user_el(data.value)
        label = @options.chose_user_label.clone()
        label = @_selector(data, li, label)
        label.html(user_el)
        label.append(@options.close_label.clone())

      _selector: (data, li, label) ->
        @options.input.focus()
        _data = {value: data, html: li}

        @set_data(label[0], _data)
        @selector_panel.append(label)
        @options["selector"](_data, li)
        label

      create_user_el: (value) ->
        span = $("<span />")
        span.append("<i class='icon-user' />")
        span.append(value)
        span

      create_element: () ->
        @selector_panel = $("<span class='chose-item-selector' />")
        @input_panel = $("<div class='chose-input' />")

        @options.el.append(@input_panel)
        @input_panel.append(@selector_panel)
        @input_panel.append(@options.input)

      defulat_opts: {
        template: "<a>{{name}}</a>"

        value: "name"

        data: []

        el: null

        complete: (data, ul) ->

        selector: (data, li) ->

        close_item: (data, li) ->

        input: $("<input type='text'/>")

        chose_circle_label: $("<span class='label label-success chose-label'>")

        chose_user_label: $("<span class='label label-info chose-label'>")

        chose_shop_label: $("<span class='label label-important chose-label'>")

        close_label: $("<a class='close-label'></a>")

        init_template: "
          <li class='chose-item' data-value='circle' data-toggle='popover' data-content='你所有的圈子' index=0><a><i class='icon-film'></i>您的圈子</a></li>
          <li class='chose-item' data-value='puliceity' data-toggle='popover' data-content='所有人可以看' index=1><a><i class='icon-fire'></i>公开</a></li>
          <li class='chose-item' data-value='external' data-toggle='popover' data-content='您圈子中的所有成员，以及这些成员的圈子中的所有人。' index=2><a><i class='icon-eye-open'></i>外扩圈子</a></li>
          <li class='chose-item divider' index=3></li>
        "

        value: ""

        default_value: ""
      }

    $.fn.choseFriend = (opts) ->
      new ChoseFriend($.extend({}, opts, {el: @}))
)
