root  = window || @

class ApplyJoinCircle extends Backbone.View

 	events: 
 		"click .add_circle" : "apply_join_circle"

 	apply_join_circle: () ->
 		$.ajax({
 			dataType: "json",
 			url: "people/circle/apply/"+@el.id,
 			success: () ->
 				@el.html("<a href='#' class='label label-warning'>等待确认</a>")
 		})


 class ApplyJoinCircleList extends Backbone.View
 	_.each $(".businiess_communites"), (el) ->
 		new ApplyJoinCircle({ el: @el})