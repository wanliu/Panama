root = window || @

class root.LoadCategoryProduct extends Backbone.View

  initialize: () ->
    @default_options()
    _.extend(@, @options)

  fetch: (data = {}, callback = () -> ) ->

  scroll: (post) ->
    return unless @ready_fetch && @remote_state
    max_height = @$("ul.product_list")[0].scrollHeight
    _rail = @$(".slimScrollRail").outerHeight()

    if post + _rail >= max_height - 50
      @remote()

  remote: () ->
    @ready_fetch = false
    @fetch @remote_options, (data) =>
      @ready_fetch = true
      @remote_state = false if data.length <= 0
      opt = @remote_options
      opt.offset = opt.offset + opt.limit

  default_options: () ->
    @remote_state = true
    @ready_fetch = true
    @remote_options = {offset: 0, limit: 40}

  reset_load: (offset) ->
    @default_options()
    @remote_options.offset = (offset || 40) # 搜索为空时，后台默认返回40条


class root.WizardView extends Backbone.View

  events:    
    "click .add_to_shop"     : "add_to_shop"
    "click .remove_from_shop": "remove_from_shop"
    "click .product_list>li" : "select_many"
    "click .select_all"      : "select_all"
    "submit form.product"    : "search_product"

  initialize: () ->
    @remote_options = {}
    @default_options()
    _.extend(@remote_options, @options.remote_options)
    @$search = @$("form.product input.search")
    template = @options['category_product_template'] || category_product_template
    @category_product_tpl ||= Hogan.compile(template)
    @$product_list = @$(".category_product_list>ul")
    @$loader = @$(".category_product_list .loader")
    @bind_typeahead()

  get_category_products: (category_id) ->
    #shop_id = @options.shop_id
    @url = "/category/#{category_id}/products"
    # category_product_template = "<option id='{{ id }}' value='{{id}}'>{{ name }}</option>"
    @default_options()
    @fetch {}, (data) =>
      @$product_list.empty()
      @load_default_fetch()

    false

  load_default_fetch: () ->

  filter_brand: () ->
    _.map @$("input[type=checkbox]:checked"), (elem) ->
      $(elem).attr("data-brand")

  btn_select_all: () ->
    @$(".select_all")

  fetch: (data = {}, callback = (data) -> ) ->
    brand = @filter_brand()
    _data = _.extend({}, @remote_options, data, { brand_name: brand})
    return if _.isEmpty(@url)
    return if @promise && @promise.state() == "pending"
    @$loader.show()
    @promise = $.ajax({
      type: "get",
      url: @url,
      dataType: "json",
      data: _data,
      success: (data) =>
        @$loader.hide()
        callback(data)
        @reset(data)
    })
    @btn_select_all().text("全选")

  add_one: (product) ->
    @$product_list.append(@category_product_tpl.render(product))

  render_product_infor: (product_ids) =>
    if product_ids.length <= 0
      pnotify(text: "请先选择产品", type: "warning")
      return false 
    $.ajax({
      type: "post",
      url: "/shop_products",
      data: {product_ids: product_ids },
      dataType: "json",
      success: (products) =>
        @options.select_handle(products)
        @$(".product_list .checked_product").remove()

      error: (xhr) ->
        try
          ms = JSON.parse(xhr.responseText).join("<br />")
          pnotify(text: ms, type: "error")
        catch error
          pnotify(text: xhr.responseText, type: "error")
    })
    false

  default_options: () ->
    _.extend @remote_options, {offset: 0, limit: 40}

  add_to_shop: () ->
    product_ids = []
    @$(".product_list .checked_product").each () ->
      product_ids.push($(this).attr("id"))

    @render_product_infor(product_ids)
    @btn_select_all().text("全选")

  select_many: (event) ->
    el = $(event.currentTarget)
    if el.hasClass('checked_product')
       el.removeClass("checked_product")
       @btn_select_all().text("全选")
    else
      el.addClass("checked_product")

  select_all: ()->
     if @btn_select_all().text() == "全选"
       $(".category_product_list .product_item").each(()->
         if !$(this).hasClass("checked_product")
           $(this).addClass("checked_product")
       )
       @btn_select_all().text("取消")
     else
       $(".category_product_list .product_item").each(()->
         if $(this).hasClass("checked_product")
           $(this).removeClass("checked_product")
       )
       @btn_select_all().text("全选")

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
       url: "/shop_products/#{@remote_options.shop_id}/delete_many",
       dataType: "json",
       success: () ->
         # alert("成功喔，亲")
     })

  bind_typeahead: () ->
    new TypeaheadExtension({
      el: @$search,
      source: "/product_search?shop_id=#{@remote_options.shop_id}",
      select: (item)  =>
        @search_product()
    })

  search_product: () ->
    query = @$search.val()
    $.ajax({
      url: "/product_search",
      data: {shop_id: @remote_options.shop_id, q: query},
      success: (data) =>
        @$product_list.empty()
        @reset(data)
    })
    false

  reset: (data) ->
    _.each data, (product) => @add_one(product)


class root.ProductView extends Backbone.View

  events:
    "submit form.search" : "search"
    "click .my_product_list>li" : "select_many"

  tr_template: "
    <tr id='{{id}}>
      <td><input type='checkbox'></td>
      <td class='name'>{{ name }} </td>
      <td class='price edit'> {{ price }}</td>
      <td class='inventory edit'> {{ inventory }}</td>
      <td><a href='#' class='delete_product'>删除</a></td>
    </tr>"

  initialize: (@options) ->
    template = @options['template'] || @tr_template
    @template = Hogan.compile(template)
    @shop = @options.shop
    @list = @$(".my_product_list")
    @$search = @$("form.search>input.query")
    @bind_typeahead()

  fetch: (data = {}, callback = () ->) ->
    $.ajax(
      url: "/shop_products/#{@shop.id}/search",
      data: {q: @keyword, offset: @list.find(">li").size()},
      success: (data, xhr, res) =>
        callback(data)
        @reset(data)
      error: (data, xhr, res) =>
        console.error(res.responseText)
    )

  reset: (data) ->
    _.each data, (model) => @add_one model

  add_one: (model) ->
    @render(model)

  render: (product) ->
    pr = @template.render(product) # product_result
    @list.append(pr)

  bind_typeahead: () ->
    new TypeaheadExtension({
      el: @$search,
      source: "/shop_products/#{@shop.id}/search",
      select: (item)  =>
        @search()
    })

  search: () ->
    @keyword = @$search.val().trim()
    $.ajax(
      url: "/shop_products/#{@shop.id}/search",
      data: {q: @keyword},
      success: (data) =>
        @list.empty()
        @reset(data)
        my_product.reset_load(@list.find(">li").size()) if my_product
      error: (xhr, res) =>
        try
          ms = JSON.parse(xhr.responseText).join("<br />")
          pnotify(text: ms, type: "error")
        catch err
          pnotify(text: xhr.responseText, type: "error")
    )
    false

  select_many: (event) ->
    el = $(event.currentTarget)
    if el.hasClass('checked_product')
      el.removeClass("checked_product")
    else
      el.addClass("checked_product")