#= require jquery
#= require lib/underscore
#= require backbone

exports = window || this
class Drag extends Backbone.View
	el: "#main_drag"
	events: {
	}
	initialize: (options) ->
		_.extend(@,options)
		@.$main = $("#main")
		@.$main.append("<div id='main_drag'></div>")
		@el = $("#main_drag")
		@el.css('left',@.$main.offset().left+@.$main.width()-3)
		@el.height((@.$main.height()+100)+"px")

		@el.bind "mousedown", $.proxy(@on_mousedown,@)
		$(document).bind "mouseup",$.proxy(@mouseup,@)

	on_mousedown: (e)->
		# $(document).bind "selectstart",$.proxy(@selectstart,@)
		# $(document).bind "contextmenu",$.proxy(@contextmenu,@)
		$("body").css('cursor','w-resize')
		@.$main.css("border","2px dashed gray")
		@el.css("border-right","0px dashed gray")
		$("body").css('-moz-user-select','none')
		$("body").css('-webkit-user-select','none')
		offset = @el.offset();
		@x = e.pageX - offset.left;
		@y = e.pageY - offset.top;
		$(document).bind "mousemove",$.proxy(@mousemove,@)

	mousemove: (ev)->
		$("#main_drag").stop();
		_x = ev.pageX - @x;
		if _x < $(window).width()
			$("#main_drag").animate({left:_x+"px",top:"0px"},10)
			strWidth = 1235
			if _x > 861 && _x < 1100
				strWidth = 996
			else if _x > 621 && _x < 860
				strWidth = 755
			else if _x > 391 && _x < 620
				strWidth = 515
			else if _x > 1 && _x < 390
				strWidth = 270

			$("#social_sidebar").css('left',strWidth+"px")
			$("#main").width(strWidth+"px")
			$("#activities").data("masonry").resize()

	mouseup: ()->
		$(document).unbind("mousemove");
		# $(document).unbind("selectstart");
		# $(document).unbind("contextmenu");
		$("#main_drag").css('left',$("#main").offset().left+$("#main").width()-3)
		@.$main.css("border","0px solid gray")
		@el.css("border-right","5px solid #ccc")
		$("#main_drag").height($("#main").height()+"px")
		$("body").css('cursor','')
		$("body").css('-moz-user-select','')
		$("body").css('-webkit-user-select','')

	selectstart: ()->
		return false

	contextmenu: () ->
		return false

exports.Drag = Drag
exports