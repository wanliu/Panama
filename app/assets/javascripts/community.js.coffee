#= require panama
#= require ajaxify
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require backbone
#= require following
#= require topic
#= require circles
#= require circle_member

root = window || @

class CircleCategory extends Backbone.View

	initialize: () ->
		_.extend(@, @options)

	events:
		"click .add_category" : "edit"
		"blur .new_category" : "submit"
		"keyup .new_category" : "enter"

	enter: (e) ->
		@$(".new_category").blur() if e.keyCode == 13

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
				
				url: "/communities/#{ @circle_id }/categories",
				success: (data) =>
					$("<li>
            <a data-value-id='#{ data.id}' href='/communities/#{@circle_id}/category/#{data.id}' class='circle-category-#{data.id}'>
              #{ data.name}
            </a>
          </li>").appendTo("#community-side-nav")
			})

root.CircleCategory = CircleCategory
