root = window || @

class root.WizardView extends Backbone.View

  @category_product_template = "<option id='{{ id }}' value='{{id}}'>{{ name }}</option>"

  events:
    "click .leaf_node" : "get_category_products"
    "click .add_to_shop" : "add_to_shop"
    "click .label-default" : "edit_shop_product"
    "click .delete_product" : "delete_product"
    "click .deleteAll" : "deleteAll"
    "click .category_product_list > li" : "select_many"
    "click .select_all" : "select_all"

  edit_shop_product: (event) ->
    return if $(event.currentTarget.className).is('.input')
    area = $(event.currentTarget)
    li = area.parent()

    area.addClass('input')
      .html("<input type='text' value='#{area.text()}' />")
      .find('input')
      .focus()
      .blur(() ->
        area.removeClass('input').html($(this).val() || 0).append("<i class='icon-edit'></i>")
        id = li.parent().attr("id")
        field = area
        value = area.text()
        update_product(id, field, value)
      )

  get_category_products: (event) ->
    shop_id = @options.shop_id
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

  add_to_shop: () ->
    product_ids = []
    $(".checked_product").each () ->
      product_ids.push($(this).attr("id"))
      $(this).remove()
    @render_product_infor(product_ids)

  update_product = (product_id, field, value) ->
    data = if field.hasClass("price")
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

  select_many : (event) ->
    el = $(event.currentTarget)
    if el.hasClass('checked_product')
      el.removeClass("checked_product")  
    else
      el.addClass("checked_product")

  select_all : ()->
    if $(".select_all").text() == "全选"
      $(".category_product_list .product_item").each(()->
        if !$(this).hasClass("checked_product")
          $(this).addClass("checked_product")
      )
      $(".select_all").text("取消")
    else
      $(".category_product_list .product_item").each(()->
        if $(this).hasClass("checked_product")
          $(this).removeClass("checked_product")
      )
      $(".select_all").text("全选")

  # deleteAll: () ->
  #   $('input[type="checkbox"]:checked').each((i,el) =>
  #     tr = $(el).parents("tr")
  #     product_id = $(el).parents("tr").attr("id")
  #     @delete_product(tr,product_id)
  #   )

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
