
root = window || @

class DependSelectView extends Backbone.View
	initialize: (options) ->		
		_.extend(@, options)
		@el = $(@el)
		@el.bind("change", $.proxy(@select_change,@)) if @children != ""
		@el.data("depend", @)

	select_change: () ->
		@reset()
		$(@children).data().depend.load_data(@el.val())

	load_data: (opt) ->
		$.ajax({
			url: @url+opt,
			dataType: 'json',
			data: {},
			success: $.proxy(@callback,@)
		})

	callback: (data) =>		
		strHtml = "<option value=''>--请选择--</option>"
		_.each data, (num) =>
			strHtml += "<option value='#{num["id"]}'>#{num["name"]}</option>"
		@el.html(strHtml)
		@call_back.call(@, data)  if _.isFunction(@call_back)

	reset: () ->
		$(@children).data().depend.el.html("") if this.children != ""
		$(@children).data().depend.reset() if $(@children).data().depend.children != ""


root.DependSelectView = DependSelectView
