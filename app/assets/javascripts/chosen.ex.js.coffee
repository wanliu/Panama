#= require chosen.jquery

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

# $('object').chooseEx( {
#	remote: {
#      url: '/products',
#      method: 'GET',
#      dataType: 'json',
#      callback: function() {
#	
#      }
#   }
# })

# $('object').chosenEx({
#   remote: '/product'	
# })

#<%= f.input :selecct, :as =>:chosen, :input_html =>{ :style => "width:350px;", :remote_url => "/detalls/search"} %>

class ChosenEx extends Chosen

	constructor: (@form_field, @options={}) ->
		super(@form_field, @options)
		blurHandle = @options['blur']
		remote_options = @options['remote']
		if typeof remote_options == 'string'
			@remote_options = $.extend({}, @default_remote_options)
			@remote_options.url = remote_options
			@remote_options.callback = @remote_callback
		else if $.isPlainObject(remote_options)
			@remote_options = $.extend(@default_remote_options, remote_options)
			@remote_options.callback = @remote_callback

 		@results_none_found = @remote_options.no_results_text
		if $.isFunction(blurHandle)
			@bindFunctionGround('input_blur', blurHandle) 

		if @remote_options.remote_url?
			@search_field.unbind()
			@search_field.bind('keyup', $.proxy(@keyupRemote,@))

	default_remote_options: {
		method: 'GET',
		dataType: 'json',
		callback: "remote_callback",
		no_results_text: "没有匹配结果!"
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
	    if @remote_options.remote_url?
	    	@search_param = search_param
	    	$.get @remote_options.remote_url, {search_param: search_param}, $.proxy(@remote_options.callback,@)

	remote_callback: (data) ->  
		products = JSON.parse(data)
		text_class = this.form_field.id+"_on_text"
		if $("."+text_class).length <= 0
			@text_html()
 		
 		@textObj = $("."+text_class)
		if products.length > 0 
			@strHtml = "<option value='"+num._id+"'>"+num.age+"</option>" for num in products
			@textObj.hide()
		else
			@strHtml = "<option value=''></option>"
			@textObj.show()

		$(this.form_field).html(@strHtml)
		$(this.form_field).trigger("liszt:updated")
		@search_field.val(@search_param)
 
	text_html: () ->
		@strH = @remote_options.no_results_text
		@search_results.parent().append("<div class='"+this.form_field.id+"_on_text' style='padding-left:8px;padding-bottom:7px' >"+@strH+"</div>")