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
        @el.show()

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

    class ChoseFriend
      defulat_opts: {
        template: "<a>{{name}}</a>"

        value: "name"

        data: []

        el: null

        complete: (data, ul) ->

        selector: (data, li) ->

        input: $("<input type='text'/>")

        chose_label: $("<span class='label label-success chose-label'>")

        close_label: $("<a class='close-label'></a>")

        init_template: "
          <li class='chose-item' data-value='circle' index=0><a><i class='icon-film'></i>您的圈子</a></li>
          <li class='chose-item' data-value='puliceity' index=1><a><i class='icon-fire'></i>公开</a></li>
          <li class='chose-item' data-value='external' index=2><a><i class='icon-eye-open'></i>外扩圈子</a></li>
          <li class='chose-item divider' index=3></li>
        "

        value: ""

        default_value: ""
      }
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
        @options.el.append(@drop_down.render())

        @load_css()
        @events()

      set_options: (opts) ->
        $.extend(@options, @defulat_opts, opts)

      load_css: () ->
        @options.el.addClass("chose-friend")

      events: () ->
        @input_panel.bind "click", () =>
          @options.input.focus()
          event.stopPropagation()

        @options.input.focus () =>
          @drop_down.show()
          event.stopPropagation()

        $(window).click () =>
          @drop_down.hide()

        @drop_down.ul_el.on "click", "li", (event) =>
          data = $.data event.currentTarget, "data"
          @selector(data, $(event.currentTarget))
          event.stopPropagation()

        @selector_panel.on "click", ".close-label", (event) =>
          @close_item(event)
          event.stopPropagation()

      close_item: (event) ->
        parent_el = event.currentTarget.parentElement
        data = $.data parent_el, "data"
        if data?
          @show_item(data.html)

        $(parent_el).remove()

      show_item: (li) ->
        @drop_down.ul_el.append(li)
        @sort_item()

      sort_item: () ->
        $("li", @drop_down.ul_el).each (i, bli) =>
          $("li", @drop_down.ul_el).each (j, ali) ->
            bindex = parseInt($(bli).attr("index"))
            aindex = parseInt($(ali).attr("index"))
            if bindex > aindex
              $(bli).before($(ali))

      load_default_value: (_data) ->
        if @options.value? && @options.default_value? &&
         @options.value != "" && @options.default_value != ""
          $("li", @drop_down.ul_el).each (i, li) =>
            data = $.data(li, "data")
            if data?
              if data[@options.value] == @options.default_value
                $(li).click()
                @drop_down.hide()
                @options.input.blur()

      selector: (data, li) ->
        @options.input.focus()
        label = @options.chose_label.clone()

        unless data?
          data = li.attr("data-value")

        $.data label[0], "data", {values: data, html: li}

        label.html(li.remove().find("a").html())
        label.append(@options.close_label.clone())
        @selector_panel.append(label)
        @options["selector"](data, li)

      create_element: () ->
        @selector_panel = $("<span class='chose-item-selector' />")
        @input_panel = $("<div class='chose-input' />")

        @options.el.append(@input_panel)
        @input_panel.append(@selector_panel)
        @input_panel.append(@options.input)

    $.fn.choseFriend = (opts) ->
      new ChoseFriend($.extend({}, opts, {el: @}))
)
