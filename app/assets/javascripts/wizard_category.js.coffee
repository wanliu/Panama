(() ->
  $(() ->
    $("#category-sidebar a").bind("click", (event) ->
      $(".accordion-body").hide()
      url =  event.target.attributes.href.value + "/products"
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
      false
      )

    $("input[name=get_select]").bind("click",()->
      $("select[name=product] option:selected").each(() ->
        $.ajax({
          type: "get",
          url: "/products/#{$(this).val()}/base_info",
          dataType: "json",
          success: (product) =>
            debugger
            $("table tr:last").after(
              "<tr id="+product.id+"> 
              <th>"+product.name+"</th>
              <td>"+product.price+"</td>
              <td>"+"1"+"</td> </tr>"
              )
            })
        )
      )
    )
).call(this)
