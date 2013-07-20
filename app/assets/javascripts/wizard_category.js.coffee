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
        dataType: "json",
        success: (product) =>
          $("table tr:last").after(
            "<tr id="+product.id+">
            <th>"+product.name+"</th>
            <td>"+product.price+"</td>
            <td>"+"1"+"</td> </tr>"
          )
      })

    $('table td').live('click', () ->
      if $(this) isnt ('.input')
        $(this).addClass('input')
          .html('<input type="text" value="'+ $(this).text() +'" />')
          .find('input')
          .focus().blur(() ->
              debugger
              $(this).parent().removeClass('input').html($(this).val() || 0)
          )
    )

    update_product = (product_id) ->
      $.ajax({
        type: "post",
        url: "/shop_products/product_id",
        dataType: "json",
        error: (messager) ->
          alert("操作失败")
      })
  )
).call(this)