#=require lib/tree_slide

root = window || @

class BrandChoiceView extends Backbone.View

  template: Handlebars.compile(
    """<div class="span3" style="width:30%;">
        <div class='brand_line'>
          <input type="checkbox"  data-brand="{{brand_name }}" />
          <span>{{ brand_name }}</span>
        </div>
      </div>""")

  events:
    "click .pick_brand" : "judge"
    "click .apply"      : "apply"
    "click .cancle"     : "cancle" 
    "click .leaf_node"  : "_get_category_products"

  apply: () ->
    brand_name = []
    _.each @$("input[type=checkbox]:checked"), (elem) ->
      brand_name.push($(elem).attr("data-brand"))
    @ganerate_tree(brand_name)
    @cancle()

  ganerate_tree: (brand_name) =>
    $.ajax({
      type: "get",
      url: "/category/filtered_brand",
      data: { brand_name: brand_name},
      success: (html) =>
        @$(".category_tree").html(html)
        new TreeSlide({ el: @$(".tree-nav") })
    })

  cancle: () ->
    @$(".brand_list").css("display","none")

  judge: () =>
    @$(".brand_list").css("display","block")
    if @$(".brand_content")
      @pick_brand()

  pick_brand: () =>
    $.ajax({
      type: "get",
      url: "/products/all_brand_name",
      success: (datas) =>
        @render(datas)
    })

  render: (datas) =>
    result = ""
    _.each datas, (data) =>
      if data.brand_name
        result += @template(data)
    @$(".brand_content").replaceWith($(result))

  _get_category_products: (event) ->
    if _.isFunction(@options.get_category_products)
      category_id = $(event.currentTarget).attr("data-id")
      @options.get_category_products(category_id) 


root.BrandChoiceView = BrandChoiceView