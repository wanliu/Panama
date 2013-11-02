root = window || @

class CircleCategory extends Backbone.View

	initialize: () ->
		_.extend(@, @options)

	events:
		"click .add_category" : "edit"
		"blur .new_category" : "submit"

	edit: () ->
		@$(".add_category").hide()
		input = $("<input type='text' placeholder='新类别' class='new_category span11'/>").insertBefore(".add_category")
		input.focus()

	submit: () ->
		$category_name = $(".new_category").val()
		@$(".new_category").remove()
		@$(".add_category").show()
		if $category_name != ""
			$.ajax({
				type: "post",
				dataType: "json",
				data: { name: $category_name },
				url: "/communities/#{ @circle_id }/circles/add_category",
				success: (data) =>
					$("<li><a data-value-id='#{ data.id}' href='#' class='circle-category-#{data.id}'>#{ data.name} </a></li>").insertBefore(".add_category")	
			})

root.CircleCategory = CircleCategory