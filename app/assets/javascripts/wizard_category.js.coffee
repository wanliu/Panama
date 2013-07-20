(() ->
  $(() ->
    $("#category-sidebar a").bind("click", (event) ->
      $(".accordion-body").hide()
      url =  event.target.attributes.href.value + "/products"
      get_category_products(url)
      false
    )

    $("input[name=get_select]").bind("click",()->
      $("select[name=product] option:selected").each(get_and_render_product_infor)
    )

    get_category_products = (url) ->
      $.ajax({
        type: "get",
        url: url,
        dataType: "json",
        success: (data) =>
          $("select[name=product]").html("")
          _.each(data, (product)->
            $("select[name=product]").append("<option value="+product.id+">"+product.name+"</option>")
          )
      })

    get_and_render_product_infor = () ->
      $.ajax({
        type: "post",
        url: "/shop_products",
        data: {product_id: $(this).val() }
        dataType: "json",
        success: (product) =>
          $("table tr:last").after(
            "<tr id="+product.id+">
            <th class='name'>"+product.name+"</th>
            <td class='price'>"+product.price+"</td>
            <td class='inventory'>"+product.inventory+"</td> </tr>"
          )
      })

    $('table td').live 'click', () ->
      if !$(this).is('.input')
        $(this).addClass('input')
          .html("<input type='text' value='#{$(this).text()}' />")
          .find('input')
          .focus()
          .blur(() ->
            $(this).parent().removeClass('input').html($(this).val() || 0)
            id = $(this).parent().attr("id")
            field = $(this).attr("class")
            value = $(this).val()
            update_product(id, field, value)
          )
    

    update_product = (product_id, field, value) ->
      data = if field is "price"
        shop_product:
          price: value
      else
        shop_product:
          inventory: value

      $.ajax({
        type: "put",
        url: "/shop_products/#{product_id}",
        dataType: "json",
        data: data
        success: () ->
          alert("s")
        error: (messager) ->
          alert("e")
          
      })
  )
).call(this)