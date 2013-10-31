root = window || @

class CircleCategory extends Backbone.View

	initialize: () ->
		_.extend(@, @options)
	
	events: 
		"click .add_category" : "edit"
		"blur .new_category" : "submit"
		"click .remove_category" : "remove"

	remove: (e) ->
		a = e.currentTarget.parentElement
		id = $(a).attr("data-value-id")
		$.ajax({
			type: "delete",
			dataType: "json",
			data: { category_id: id }
			url: "/communities/#{ @circle_id }/circles/del_category",
			success: () =>
				a.remove();
		})
	
	edit: () ->
		@$(".add_category").hide()
		$("<input type='text' placeholder='新类别' class='new_category'/>").insertBefore(".add_category")
	
	submit: () ->
		$category_name = $(".new_category").val()
		@$(".new_category").remove()
		@$(".add_category").show()
		if $category_name != ""
			$.ajax({
				type: "post",
				dataType: "json",
				data: { name: $category_name },
				url: "/communities/#{ @circle_id }/circles/category",
				success: (data) =>
					$("<a data-value-id='#{ data.id}' href='#' class='circle-category-#{data.id}'>#{ data.name}  <i class='icon-remove remove_category'></i> </a>").insertBefore(".add_category")	
			})

root.CircleCategory = CircleCategory