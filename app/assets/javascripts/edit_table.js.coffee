(() ->
	$(() ->
		$('table td').live('click', () ->
			if $(this) isnt ('.input')
				$(this).addClass('input').html('<input type="text" value="'+ $(this).text() +'" />').find('input').focus().blur(() ->
					$(this).parent().removeClass('input').html($(this).val() || 0);
				).hover(()->
					$(this).addClass('hover')
				,()->
					$(this).removeClass('hover')
			)
		)

		update_product = (product_id) ->
			$.ajax({
        type: "post",
        url: "/shop_products/#{$(this).val()}",
        dataType: "json",
        success: () ->
      })

	)
).call(this)