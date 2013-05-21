define ["jquery",'backbone'], ($,@options) ->

	class ChangeNumber extends Backbone.View
		
		events : {
			"click .spinner-up.up" : "change"
			"click .spinner-down.down" : "change"
		}

		initialize: (@options) ->
			_.extend(@, options)
			@$el = $(@el)

		change : () -> 
			@amount = $(".spinner-input").val()
			@item_id = $(".product-item").attr("data-value-id")       
			$.ajax({
				type: "post",
				url: "/people/#{@login}/cart/#{@item_id }/change_number",  
				data : { amount : @amount }           
				dataType: "json"
			}) 

