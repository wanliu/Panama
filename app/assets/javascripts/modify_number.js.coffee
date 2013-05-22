define ["jquery",'backbone'], ($, Backbone) ->

	class ChangeNumber extends Backbone.View
		
		events : {
			"click .spinner-up" : "change"
			"click .spinner-down" : "change"
		}

		initialize: (options) ->
			debugger
			_.extend(@, options)
			@$el = $(@el)

		change : () -> 
			debugger
			@amount = @$el.find(".spinner-input").val()
			@item_id = @$el.attr("data-value-id")       
			$.ajax({
				type: "post",
				url: "/people/#{@login}/cart/#{@item_id }/change_number",  
				data : { amount : @amount }           
				dataType: "json"
			}) 

