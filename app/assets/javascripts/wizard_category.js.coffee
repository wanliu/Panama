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
          $("textarea[name=product]").html("")
          _.each(data, (product)->
            $("textarea[name=product]").append(product.name+"\n")
          )
      })
      false
    )
  )
).call(this)
