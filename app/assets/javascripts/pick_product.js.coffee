root = window || @

class root.WizardView extends Backbone.View
  events:
    "click .second_class_category_tree a" : "get_category_products"
    "click .add_to_select" : "get_products_infor"
    "click .edit" : "edit_table"
    "click .delete_product" : "delete_product"
    "click .deleteAll" : "deleteAll"
    "click .select_all" : "selectAll"

  edit_table: (event) ->
    return if $(event.target.className).is('.input')
    td = $(event.target)
    tr = td.parent()
    
    td.addClass('input')
      .html("<input type='text' value='#{td.text()}' />")
      .find('input')
      .focus()
      .blur(() ->
        $(this).parent().removeClass('input').html($(this).val() || 0)
        id = tr.attr("id")
        field = td.attr("class")
        value = td.text()
        update_product(id, field, value)
      )

  get_category_products: (event) ->
    $body = $(event.target).parents(".accordion-body")
    $body.removeClass("in").attr("style", "")
    @url =  event.target.attributes.href.value + "/products"
    $.ajax({
      type: "get",
      url: @url,
      dataType: "json",
      success: (data) =>
        $("select[name=product]").html("")
        _.each(data, (product)->
          $("select[name=product]").append("<option value="+product.id+">"+product.name+"</option>")
        )
    })
    false

  render_product_infor: () ->
    $.ajax({
      type: "post",
      url: "/shop_products",
      data: {product_id: $(this).val() }
      dataType: "json",
      success: (product) =>
        product_view = new ProductView(model: product)
    })

  get_products_infor: () ->
    $("select[name=product] option:selected").each(@render_product_infor)
        
  update_product = (product_id, field, value) ->
    data = if field is "price edit"
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
      error: (messager) ->
        alert(messager)
    })

  selectAll : () ->
    $("input[type=checkbox]").each(() ->
      $(this).attr("checked",!this.checked);  
    )

  deleteAll: () ->
    $('input[type="checkbox"]:checked').each((i,el) =>
      tr = $(el).parents("tr")
      product_id = $(el).parents("tr").attr("id")
      @delete_product(tr,product_id)
    )

  delete_product: (tr,product_id) =>
    if $(event.target).attr("class") is 'delete_product'
      tr = $(event.target).parents("tr")
      product_id = tr.attr("id")
    else 
      product_id = product_id
      tr = tr
    $.ajax({
      type: "delete",
      url: "/shop_products/#{product_id}",
      dataType: "json",
      success: () ->
        tr.remove()
    })   

class root.ProductView extends Backbone.View
  tagName: 'tr'
   
  initialize: (@options) ->
    @product = @options['model']
    @render()

  render: (product) ->
    $(@el).html("<td><input type='checkbox'></td>
                <td class='name'>#{ @product.name } </td>
                <td class='price edit'> #{@product.price }</td>
                <td class='inventory edit'> #{ @product.inventory }</td> 
                <td><a href='#' class='delete_product'>删除</a></td>")
    $(@el).attr('id', @product.id)
    $("table tbody").append(@el)
    @



