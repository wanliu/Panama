#= require 'jquery'
#= require 'lib/chosen.jquery'

root = window || @

$.fn.extend({
    chosenEx: (options) ->
      ua = navigator.userAgent.toLowerCase();

      match = /(msie) ([\w.]+)/.exec( ua ) || [];

      browser =
        name: match[ 1 ] || ""
        version: match[ 2 ] || "0"

      # Do no harm and return as soon as possible for unsupported browsers, namely IE6 and IE7
      # Continue on if running IE document type but in compatibility mode
      return this if browser.name is "msie" and (browser.version is "6.0" or  (browser.version is "7.0" and document.documentMode is 7 ))
      this.each((input_field) ->
        $this = $ this
        $this.data('chosen', new ChosenEx(this, options)) unless $this.hasClass "chzn-done"
      )
})

class ChosenEx extends Chosen

  constructor: (@form_field, @options={}) ->
    super(@form_field, @options)
    blurHandle = @options['blur']
    remote_options = @options['remote']
    if typeof remote_options == 'string'
      @remote_options = $.extend({}, @default_remote_options())
      @remote_options.url = remote_options
      @remote_options.callback = @remote_callback
    else if $.isPlainObject(remote_options)
      @remote_options = $.extend(@default_remote_options(), remote_options)
      @remote_options.callback = @remote_callback

    @results_none_found = @remote_options.no_results_text
    if $.isFunction(blurHandle)
      @bindFunctionGround('input_blur', blurHandle)

    if @remote_options.url != ""
      @search_field.unbind()
      @search_field.bind('keyup', $.proxy(@keyupRemote, @))

    if $.isFunction(@options.reset)
      @form_field_jq.bind('reset', $.proxy(@options.reset, @))

    @remote_callback(@options.data) if $.isArray(@options.data)

  default_remote_options: () ->
    return {
      method: 'GET',
      dataType: 'jsonp',
      callback: "remote_callback",
      no_results_text: "没有匹配结果!",
      remote_value: "id",
      remote_key: "name",
      param_name: "q"
    }

  bindFunctionAfter: (event, handle) ->
    @events ||= {}
    @events[event] = @[event]
    @[event] = (args...) =>
      @events[event].apply(@,args)
      handle.apply(@, args)

  bindFunctionBefore: (event, handle) ->
    @events ||= {}
    @events[event] = @[event]
    @[event] = (args...) =>
      handle.apply(@, args)
      @events[event].apply(@,args)

  bindFunctionGround: (event, handle) ->
    @events ||= {}
    @events[event] = @[event]
    @[event] = (args...) =>
      args.unshift(@events[event])
      handle.apply(@, args)

  keyupRemote: (event) ->
    search_value = $(event.target).val().trim()
    key_code = event.keyCode || event.which
    if search_value != "" && @last_keyword != search_value
      @fetchRemote(search_value)

    switch key_code
      when 40
        @key_highlighted(1)
      when 38
        @key_highlighted(-1)
      when 13
        @select_item()

  fetchRemote: (search_value) ->
    if @remote_options.url?
      @last_keyword = search_value
      data = {}
      data[@remote_options.param_name] = search_value
      $.ajax({
        url: @remote_options.url,
        dataType: @remote_options.dataType,
        data: data,
        success: (data) =>
          @remote_options.callback.apply(@, arguments)
      })

  remote_callback: (data) ->
    strHtml = ""
    # products = JSON.parse(products)
    text_class = this.form_field.id+"_on_text"
    if $("."+text_class).length <= 0
      @text_html()

    @textObj = $("."+text_class)
    if data.length > 0
      strHtml += "<option value='"+num[@remote_options.remote_value]+"'>"+num[@remote_options.remote_key]+"</option>" for num in data
      @textObj.hide()
    else
      strHtml = "<option value=''></option>"
      @textObj.show()

    $(this.form_field).html(strHtml)
    $(this.form_field).trigger("liszt:updated")

  text_html: () ->
    @strH = @remote_options.no_results_text
    @search_results.parent().append("<div class='"+this.form_field.id+"_on_text' style='padding-left:8px;padding-bottom:7px' >"+@strH+"</div>")

  key_highlighted: (index) ->
    curre_index = @active_index() + index

    lis = @search_results.find(">li")
    if curre_index > lis.length - 1
      curre_index = 0

    if curre_index < 0
      curre_index = lis.length - 1

    lis.removeClass("highlighted")
    $(lis[curre_index]).addClass("highlighted")

  select_item: () ->
    li = @get_active_elem()
    li.bind("mouseup", (event) =>
      @search_results_mouseup(event)
    )
    li.trigger("mouseup")
    li.unbind("mouseup")

  active_index: () ->
    lis = @search_results.find(">li")
    lis.index(@get_active_elem())

  get_active_elem: () ->
    @search_results.find(">li.highlighted")