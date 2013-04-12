#describe: 选择圈子与范围

define ["jquery", "twitter/bootstrap/tooltip", "twitter/bootstrap/popover"],($) ->
    class ChoseDropDown
      el: $("<div class='chose-drop-down' />")
      ul_el: $("<ul class='chose-friend-menu' />")
      line_li: $("<li class='chose-item divider'></li>")
      init_template: ""
      match: /\{\{(\w{1,})\}\}/i
      status: true
      circle_class: "circle-line"
      followings_class: "followings-line"
      circle_complete: (data) ->
      followings_complete: (data) ->

      constructor: (opts) ->
        $.extend(true, @, opts)
        @el.append(@ul_el)
        @render_init_template()

      render_init_template: () ->
        @ul_el.html(@init_template)

      render_line_li: (class_name) ->
        li = @line_li.clone()
        li.addClass(class_name).attr("index", @get_li_index())
        @ul_el.append(li)

      render: () ->
        @el

      show: () ->
        if @el.css("display") is "none"
          @el.show()
          @el.trigger("hide")

      hide: () ->
        @el.hide()

      fetch_circle: (callback) ->
        @circle_complete = callback if $.isFunction(callback)
        if $.isArray(@circle.data)
          @all_circle_data @circle.data
        else if typeof @circle.data == "string"
          @remote @circle.data, $.proxy(@all_circle_data, @)

      fetch_following: (callback) ->
        @followings_complete = callback if $.isFunction(callback)
        if $.isArray(@followings.data)
          @all_following_data @followings.data
        else if typeof @followings.data == "string"
          @remote @followings.data, $.proxy(@all_following_data, @)

      remote: (url, callback) ->
        $.get(url, {}, callback, "json")

      all_circle_data: (data) ->
        @render_line_li(@circle_class) if data.length > 0
        $.each data, (i, val) =>
          @add_circle_one(val)

        @circle_complete(data)

      add_circle_one: (val) ->
        li = @render_li val, @circle.template
        li.addClass("circle")
        @ul_el.append(li)
        @load_data(li[0], $.extend(val, {_status: "circle"}))

      all_following_data: (data) ->
        @render_line_li(@followings_class) if data.length > 0
        $.each data, (i, val) =>
          @add_following_one(val)

        @followings_complete(data)

      add_following_one: (val) ->
        li = @render_li val, @followings.template
        li.addClass("following")
        @ul_el.append(li)
        @load_data(li[0], $.extend(val, {_status: "shop"}))

      get_li_index: () ->
        @ul_el.find("li").length

      render_li: (val, _template) ->
        attr = @match.exec _template
        while attr? && attr.length > 0
          value = val[attr[1]]
          _template = _template.replace @match, value
          attr = @match.exec _template

        $("<li class='chose-item' index=#{@get_li_index()} />").html(_template)

      load_data: (li, data) ->
        $.data li, "data", data

    class ChoseUser
      ul_el: $("<ul class='user-shop-list' />")
      li_el: $("<li />")
      el: $("<div class='user-shop-panel' />")

      constructor: (options) ->
        $.extend(@, options)
        @events()
        @el.html(@ul_el)
        @results = {}

      events: () ->
        @input.bind "keyup", () =>
          clearTimeout(@time_id) if @time_id?
          @time_id = setTimeout($.proxy(@fetch_user_shop, @), 300)

      fetch_user_shop: () ->
        search_val = @input.val().trim()
        if search_val isnt ""
          if @results.hasOwnProperty(search_val)
            @all_result @get_result(search_val)
          else
            $.get "/search/users", {q: search_val, limit: 15}, (data) =>
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
        $.each data, (i, model) =>
          @add_user model

      add_user: (model) ->
        unless @find_user_id(model.id)
          li = @add_el(model.icon_url, model.login)
          @set_data(li[0], $.extend({}, model, {_status: "user", value: model.login}))

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
        $("<span class='name value'>#{name}</span>")

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
          circle: @options.circle,
          followings: @options.followings,
          init_template: @options.init_template
        )
        @load_init_data()
        @drop_down.fetch_circle()
        @drop_down.fetch_following($.proxy(@load_default_value, @))

        @chose_view = new ChoseUser(
          input: @options.input,
          selector_data: $.proxy(@selector_data, @)
        )

        @chose_view.el.bind("hide", $.proxy(@drop_down.hide, @drop_down))
        @chose_view.el.bind("show", $.proxy(@drop_down.show, @drop_down))
        @drop_down.el.bind("hide", $.proxy(@chose_view.hide, @chose_view))

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
        $.extend(true, @options, @defulat_opts, opts)

      load_css: () ->
        @options.el.addClass("chose-friend")

      events: () ->
        @input_panel.bind "click", (event) =>
          @options.input.focus()
          event.stopPropagation()

        @options.input.focus (event) =>
          unless @chose_view.is_show()
            @drop_down.show()

          event.stopPropagation()

        $(window).click () =>
          @chose_view.input.val("")
          @chose_view.hide()
          @drop_down.hide()

        @drop_down.ul_el.on "click", "li.circle, li.init-item", (event) =>
          data = @get_data event.currentTarget
          @selector_circle(data, $(event.currentTarget))
          event.stopPropagation()

        @drop_down.ul_el.on "click", "li.following", (event) =>
          data = @get_data event.currentTarget
          @selector_following(data, $(event.currentTarget))
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
        if data.html? && status isnt "user"
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

      load_init_data: () ->
        $("li", @drop_down.ul_el).each (i, li) =>
          unless data?
            data = $(li).attr("data-value")
            @set_data(li, data)

      load_default_value: (_data) ->
        if @options.circle.default_value? && @options.circle.default_value != ""
          $("li", @drop_down.ul_el).each (i, li) =>
            data = @get_data(li)
            @default_value(data, li)

      default_value: (data, li) ->
        if data?
          if (@options.circle.value? && @options.circle.value != "" &&
          data[@options.circle.value] == @options.circle.default_value) ||
          data == @options.circle.default_value
            $(li).click()
            @drop_down.hide()
            @options.input.blur()

      set_data: (li, data) ->
        $.data li, "data", data

      get_data: (li) ->
        $.data(li, "data")

      selector_circle: (data, li) ->
        unless @filter_status_shop()
          @confrim_circle(data, li)
        else
          @_selector_circle(data, li)

      _selector_circle: (data, li) ->
        label = @options.chose_circle_label.clone()
        label.html(li.remove().find("a").html())
        @_selector(data, li, label)

      filter_status_shop: () ->
        items = @selector_data()
        for item in items
          return false if item.value._status == "shop"
        true

      selector_following: (data, li) ->
        items = @selector_data()
        if items.length > 0
          @confrim_following data, li
        else
          @_selector_following data, li

      _selector_following: (data, li) ->
        @close_all_selector_item()
        label = @options.chose_shop_label.clone()
        label.html(li.remove().find("span.value").html())
        @_selector(data, li, label)

      selector_user: (data, li) ->
        label = @options.chose_user_label.clone()
        user_el = @create_user_el(data.value)
        label.html(user_el)
        @_selector(data, li, label)

      _selector: (data, li, label) ->
        @options.input.focus()
        _data = {value: data, html: li}

        @set_data(label[0], _data)
        @selector_panel.append(label)
        label.append(@options.close_label.clone())
        @options["selector"](_data, li)
        label

      confrim_circle: (data, li) ->
        @confrim_message()

        @options.el.find("input.replace").click () =>
          @close_all_selector_item()
          @_selector_circle data, li
          @selector_panel.popover("hide")

        @options.el.find("input.cancel").click () =>
          @selector_panel.popover("hide")

      confrim_following: (data, li) ->
        @confrim_message()

        @options.el.find("input.replace").click () =>
          @_selector_following data, li
          @selector_panel.popover("hide")

        @options.el.find("input.cancel").click () =>
          @selector_panel.popover("hide")

      confrim_message: () ->
        @selector_panel.popover(
            content: "<p>如果您要与某个商店分享，就无法同时以其他方式分享相应内容。<p/><p>
            <input type='botton' class='btn btn-mini btn-primary replace'value='替换' />
            <input type='botton' class='btn btn-mini cancel' value='取消' /></p>"
            html: true
          ).popover("show")

      close_all_selector_item: () ->
        labels = @selector_panel.find(".chose-label>.close-label")
        labels.click()

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
        circle: {
          template: "<a><i class='icon-globe'></i>{{name}}({{friend_count}})</a>"

          data: []

          value: "name"

          default_value: ""
        }

        followings: {
          template: "<a><img src='{{icon_url}}' class='avatar img-polaroid' /><span class='value'>{{name}}</span></a>"

          data: []
        }

        el: null

        complete: (data, ul) ->

        selector: (data, li) ->

        close_item: (data, li) ->

        input: $("<input type='text' class='user'/>")

        chose_circle_label: $("<span class='label label-success chose-label'>")

        chose_user_label: $("<span class='label label-info chose-label'>")

        chose_shop_label: $("<span class='label label-important chose-label'>")

        close_label: $("<a class='close-label'></a>")

        init_template: "
          <li class='chose-item init-item' data-value='circle' data-toggle='popover' data-content='你所有的圈子' index=0><a><i class='icon-film'></i>您的圈子</a></li>
          <li class='chose-item init-item' data-value='puliceity' data-toggle='popover' data-content='所有人可以看' index=1><a><i class='icon-fire'></i>公开</a></li>
          <li class='chose-item init-item' data-value='external' data-toggle='popover' data-content='您圈子中的所有成员，以及这些成员的圈子中的所有人。' index=2><a><i class='icon-eye-open'></i>外扩圈子</a></li>
        "
      }

    $.fn.choseFriend = (opts) ->
      new ChoseFriend($.extend(true, {}, opts, {el: @}))