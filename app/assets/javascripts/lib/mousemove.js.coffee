
define ['jquery','backbone','exports'], ($,Backbone,exports) ->
	class Drag extends Backbone.View
		el: "#main_drag"
		events: {
		}
		initialize: (options) ->
			_.extend(@,options)
			@.$main = $("#main")
			@.$main.append("<div id='main_drag'></div>")
			@el = $("#main_drag")
			@el.css('left',@.$main.offset().left+@.$main.width()) 
			@el.height((@.$main.height()+100)+"px")

			@el.bind "mousedown", $.proxy(@on_mousedown,@)
			$(document).bind "mouseup",$.proxy(@mouseup,@)
			
		on_mousedown: (e)->
			# $(document).bind "selectstart",$.proxy(@selectstart,@)
			# $(document).bind "contextmenu",$.proxy(@contextmenu,@)
			$("body").css('-moz-user-select','none')
			$("body").css('-webkit-user-select','none') 
			offset = @el.offset();
			@x = e.pageX - offset.left;
			@y = e.pageY - offset.top;
			$(document).bind "mousemove",$.proxy(@mousemove,@)

		mousemove: (ev)-> 
			$("#main_drag").stop(); 
			_x = ev.pageX - @x;   
			$("#main_drag").animate({left:_x+"px",top:"0px"},10)
			strWidth = "996px"
			if _x > 601 && _x < 840
				strWidth = "750px" 
			else if _x > 371 && _x < 600
				strWidth = "510px" 
			else if _x > 1 && _x < 370
				strWidth = "270px" 

			$("#main").width(strWidth)
			$("#activities").data("masonry").resize()	

		mouseup: ()-> 
			$(document).unbind("mousemove"); 
			# $(document).unbind("selectstart");
			# $(document).unbind("contextmenu");
			$("#main_drag").css('left',$("#main").offset().left+$("#main").width())
			$("#main_drag").height($("#main").height()+"px")
			$("body").css('-moz-user-select','')
			$("body").css('-webkit-user-select','')

		selectstart: ()->
			return false

		contextmenu: () ->
			return false

	exports.Drag = Drag
	exports