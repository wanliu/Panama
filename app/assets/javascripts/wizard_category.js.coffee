(() ->
	$(() ->
		$("#category-sidebar a").bind("click", (event) ->
			url =  event.target.attributes.href.value + "/products"
			$.ajax({
				type: "get",
				url: url,
				dataType: "json",
				success: (data) =>
				  _.each(data, (product)->
				  	$("textarea[name=product]").append(product.name+"</br>")
				  )
			})
			false
		)
	)
).call(this)
