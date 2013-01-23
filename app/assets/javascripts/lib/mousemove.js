

define(['jquery'], function($){
	$(document).ready(function(){
		var $main = $("#main")
		$main.append("<div id='main_drag'></div>")
		// $("#main_drag").css('top',$("#main").offset().top)
		$("#main_drag").css('left',$main.offset().left+$main.width()) 
		$("#main_drag").height(($main.height()+100)+"px")

		$("#main_drag").mousedown(function(e){
			$("body").css('-moz-user-select','none')
			$("body").css('-webkit-user-select','none') 
			var offset = $(this).offset();
			var x = e.pageX - offset.left;
			var y = e.pageY - offset.top;
			$(document).bind("mousemove",function(ev){  
			    $("#main_drag").stop(); 
			    var _x = ev.pageX - x;  
			    // var _y = ev.pageY - y; 
			    $("#main_drag").animate({left:_x+"px",top:"0px"},10);
			    var width = "996px"
		        if(_x > 601 && _x < 840)     {width = "750px" }
		        else if(_x > 371 && _x < 600){width = "510px" }
		        else if(_x > 1 && _x < 370)  {width = "270px" }
		        $("#main").width(width)
			    $("#activities").data("masonry").resize()
			}); 
		});  

		$(document).mouseup(function(){
		    $(this).unbind("mousemove"); 
		    $("#main_drag").css('left',$("#main").offset().left+$("#main").width())
		    $("#main_drag").height($("#main").height()+"px")
		    $("body").css('-moz-user-select','')
			$("body").css('-webkit-user-select','')
		});


		//document.onselectstart = function(e) {
		//     return false;
		// }
		// document.oncontextmenu = function(e) {
		//     return false;
		// }
　　});
}) 
  