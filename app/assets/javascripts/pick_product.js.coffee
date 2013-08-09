root = window || @

class root.WizardView extends Backbone.View

  @category_product_template = "<option id='{{ id }}' value='{{id}}'>{{ name }}</option>"

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
    shop_id = @options.shop_id
    $body = $(event.target).parents(".accordion-body")
    $body.removeClass("in").attr("style", "")
    @url =  event.target.attributes.href.value + "/products"

    category_product_template = @options['category_product_template'] || @category_product_template
    @category_product_tpl ||= Hogan.compile(category_product_template)

    $.ajax({
      type: "get",
      url: @url,
      dataType: "json",
      data:{ shop_id : shop_id },
      success: (data) =>
        category_product_list = ".category_product_list"
        $(category_product_list).empty()
        _.each(data, (product) =>
          $(category_product_list).append(@category_product_tpl.render(product))
        )
    })
    false

  render_product_infor: (product_ids) =>
    $.ajax({
      type: "post",
      url: "/shop_products",
      data: {product_ids: product_ids },
      dataType: "json",
      success: (products) =>
        @options.select_handle(products)
    })
    false

  get_products_infor: () ->
    product_ids = []
    $("select[name=product] option:selected").each () ->
      product_ids.push($(this).val())
      $(this).remove()
    @render_product_infor(product_ids)

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
      data: data,
      error: (messager) ->
        alert(messager)
    })

  selectAll : () ->
    $("input[type=checkbox]").each(() ->
      $(this).attr("checked",!this.checked);
    )
    false

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
  tr_template: """
      <tr id='{{id}}><td><input type='checkbox'></td>
        <td class='name'>{{ name }} </td>
        <td class='price edit'> {{ price }}</td>
        <td class='inventory edit'> {{ inventory }}</td>
        <td><a href='#' class='delete_product'>删除</a></td></tr>"
  """
  initialize: (@options) ->
    @products = @options['models']
    template = @options['template'] || @tr_template
    @template = Hogan.compile(template)

    _.each @products, (model) =>
      @render(model)

  render: (product) ->
    pr = @template.render(product) # product_result
    $(@el).append(pr)
