root = window || @

class root.LoadCategoryProduct extends Backbone.View

  initialize: () ->
    @remote_state = true
    @remote_options = {offset: 0, limit: 40}
    _.extend(@, @options)

  fetch: (data = {}, callback = () -> ) ->

  scroll: (post) ->
    return unless @remote_state
    max_height = @$(".category_product_list")[0].scrollHeight
    _rail = @$(".slimScrollRail").outerHeight()

    if post + _rail >= max_height - 50
      clearTimeout(@time_out_id) if @time_out_id
      @time_out_id = setTimeout () =>
        @fetch @remote_options, (data) =>
          @remote_state = false if data.length <= 0
          opt = @remote_options
          opt.offset = opt.offset + opt.limit
      , 100


class root.WizardView extends Backbone.View

  events:
    "click .leaf_node"       : "get_category_products"
    "click .add_to_shop"     : "add_to_shop"
    "click .remove_from_shop": "remove_from_shop"
    "click .product_list>li" : "select_many"
    "click .select_all"      : "select_all"

  initialize: () ->
    @default_options()
    _.extend(@remote_options, @options.remote_options)

  get_category_products: (event) ->
    shop_id = @options.shop_id
    @url = $(event.target).attr("href") + "/products"
    category_product_template = "<option id='{{ id }}' value='{{id}}'>{{ name }}</option>"
    template = @options['category_product_template'] || category_product_template
    @category_product_tpl ||= Hogan.compile(template)
    @default_options()
    @fetch {}, (data) ->
     $(".category_product_list").empty()

    false

  fetch: (data = {}, callback = (data) -> ) ->
    _data = _.extend({}, @remote_options, data)
    return if @promise && @promise.state() == "pending"
    @promise = $.ajax({
       type: "get",
       url: @url,
       dataType: "json",
       data: _data,
       success: (data) =>
         callback(data)
         $cp_el = $(".category_product_list")
         _.each(data, (product) =>
           $cp_el.append(@category_product_tpl.render(product))
         )
    })
    $(".select_all").text("全选")

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

  default_options: () ->
    @remote_options = {offset: 0, limit: 40}

  add_to_shop: () ->
    product_ids = []
    $(".checked_product").each () ->
       product_ids.push($(this).attr("id"))
       $(this).remove()
    @render_product_infor(product_ids)
    $(".select_all").text("全选")

  select_many : (event) ->
    el = $(event.currentTarget)
    if el.hasClass('checked_product')
       el.removeClass("checked_product")
       $(".select_all").text("全选")
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

  remove_from_shop: ()->
     shop_id = @options.shop_id
     product_ids = []
     $(".my_product_list .checked_product").each ()->
       product_ids.push($(this).attr("id"))
       $(this).remove()
     # @render_product_infor(product_ids)

     $.ajax({
       type: "post",
       data:{product_ids: product_ids}
       url: "/shop_products/#{shop_id}/delete_many",
       dataType: "json",
       success: () ->
         # alert("成功喔，亲")
     })

class root.ProductView extends Backbone.View
  tr_template: "
    <tr id='{{id}}>
      <td><input type='checkbox'></td>
      <td class='name'>{{ name }} </td>
      <td class='price edit'> {{ price }}</td>
      <td class='inventory edit'> {{ inventory }}</td>
      <td><a href='#' class='delete_product'>删除</a></td>
    </tr>"

  initialize: (@options) ->
    @products = @options['models']
    template = @options['template'] || @tr_template
    @template = Hogan.compile(template)

    _.each @products, (model) =>
      @render(model)

  render: (product) ->
    pr = @template.render(product) # product_result
    $(@el).append(pr)
