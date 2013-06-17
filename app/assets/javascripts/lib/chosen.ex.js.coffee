#= require 'jquery'
#= require 'lib/chosen.jquery'

root = this
$ = jQuery

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
			@search_field.bind('keyup', $.proxy(@keyupRemote,@))

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
		if $(event.target).val() != ""
			@fetchRemote($(event.target).val())

	fetchRemote: (search_param) ->
		if @remote_options.url?
			@search_param = search_param
			# $.get @remote_options.url, {q: search_param}, $.proxy(@remote_options.callback,@)
			data = {}
			data[@remote_options.param_name] = search_param
			$.ajax({
				url: @remote_options.url,
				dataType: @remote_options.dataType,
				data: data,
				success: $.proxy(@remote_options.callback,@)
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
		@search_field.val(@search_param)

	text_html: () ->
		@strH = @remote_options.no_results_text
		@search_results.parent().append("<div class='"+this.form_field.id+"_on_text' style='padding-left:8px;padding-bottom:7px' >"+@strH+"</div>")