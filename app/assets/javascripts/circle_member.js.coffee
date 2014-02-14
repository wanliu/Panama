root = window || @

class MemberView extends Backbone.View

	events: 
		"click .up_to_manager" : "up_to_manager"
		"click .low_to_member" : "low_to_member"
		"click .remove_member" : "remove_member" 

	get_member_id: () ->
		@$el.attr("data-value-id")

	up_to_manager: () ->
		$.ajax(
			type:"post"
			url: "/communities/#{ @options.circle_id }/circles/up_to_manager"
			data: {member_id: @get_member_id()}
			success: () =>
				@$(".identy_name").html("管理员")
				@$(".up_to_manager").addClass("low_to_member").removeClass("up_to_manager")
				@$(".low_to_member").html("从成员晋升为管理员")
		)

	low_to_member: () ->
		$.ajax(
			type:"post"
			url: "/communities/#{ @options.circle_id }/circles/low_to_member"
			data: {member_id: @get_member_id()}
			success: () =>
				@$(".identy_name").html("成员")
				@$(".low_to_member").addClass("up_to_manager").removeClass("low_to_member")
				@$(".up_to_manager").html("从成员晋升为管理员")
		)

	remove_member: () ->
		$.ajax(
			type:"delete"
			url: "/communities/#{ @options.circle_id }/circles/remove_member"
			data: {member_id: @get_member_id()}
			success: () =>
				@$el.remove()
		)

class MemberList extends Backbone.View

	initialize: () ->
		_.extend(@, @options)
		els = @$(".member")
		_.each els, (el) =>
			new MemberView({
				el: el,
				circle_id: @circle_id,
			})

root.MemberList = MemberList