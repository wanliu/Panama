root = window || @

class BrandChoiceView extends Backbone.View

  template: Handlebars.compile(
    """<div class="span3" style="width:30%;">
        <div class='brand_line'>
          <input type="checkbox"  data-value＝"{{category_id }}" />
          <span>{{ brand_name }}</span>
        </div>
      </div>""")

  events:
    "click .pick_brand" : "judge"
    "click .apply"      : "apply"
    "click .cancle"     : "cancle" 

  apply: () ->
    category_id = []
    _.each $("input[type=checkbox]:checked"), (elem) ->
      category_id.push($(elem).attr("data-value"))
    hit_category = _.uniq(category_id)
    @ganerate_tree(hit_category)
    @cancle()

  ganerate_tree: (hit_category) =>
    $.ajax({
      type: "get",
      dataType: "html"
      url: "/category/filtered_tree",
      data: {category_id: hit_category},
      success: (html) =>
        debugger
        @$(".category_tree").html(html)
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
    @$(".brand_content").replaceWith(result)

root.BrandChoiceView = BrandChoiceView