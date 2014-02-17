# 分类树
root = (window || @)

class root.CategoryTree

  constructor: (options) ->
    $.extend(@, options)
    # @el.on("click", "li.expandable", $.proxy(@load_tree, @))
    # @el.on("click", "li.collapsable", $.proxy(@load_tree, @))
    @el.on("click", "li>span", $.proxy(@load_tree, @))
    @el.on("click", "li>.hitarea", $.proxy(@load_tree, @))
    @el.on("click", "li>input", $.proxy(@save_categories, @))

  save_categories: (event) ->
    category_ids = ""
    category_names = ""
    # @check_category(event)
    $(@el).find(":checked").parent("li").each (i, li) =>
      category_ids += " #{$(li).attr('data-value-id')}"
      category_names += " #{$(li).attr('data-value-name')}"
    $("#category_ids").val(category_ids.trim())
    $("#category_names").val(category_names.trim())

  check_category: (event) ->
    # 如果子类没有全选中，则使父分类不选中
    if $(event.currentTarget).parent("li").siblings("li").find("input:not(checked)").size() > 0
      $($(event.currentTarget).parents("li")[1]).find(">input")[0].checked = false
    # 如果选中某分类，则使所有子分类的不选中
    if $(event.currentTarget)[0].checked
      inputs = $(event.currentTarget).parent("li").children("ul").find(">li>input")
      inputs.each (i, el) =>
        el.checked = false
        true

  camelcase: (str) ->
    str.toUpperCase().substring(0, 1) + str.substring(1, str.length)

  hitarea_tree: (li, cls, cul) ->
    hitarea = li.find(">.hitarea")
    e_case = @camelcase(cls)
    c_case = @camelcase(cul)

    if li.hasClass("last"+ e_case)
      if hitarea.length > 0
        hitarea.removeClass("last#{e_case}-hitarea")
        hitarea.addClass("last#{c_case}-hitarea")

      li.removeClass("last#{e_case}")
      li.addClass("last#{c_case}")

    if hitarea.length > 0
      hitarea.removeClass("#{cls}-hitarea")
      hitarea.addClass("#{cul}-hitarea")

    li.removeClass(cls).addClass(cul)

  toggle_tree: (li) ->
    ul = li.find(">ul")
    if li.hasClass("expandable")
      @hitarea_tree(li, "expandable", "collapsable")
      ul.show()
    else
      @hitarea_tree(li, "collapsable", "expandable")
      ul.hide()
    @load_table(li)

  load_tree: (event) ->
    li = $(event.currentTarget).parent("li");
    ul = li.find(">ul")
    if ul.find(">li").length > 0
      @toggle_tree(li)
    else
      id = li.attr("data-value-id")
      $.ajax({
        url: "/system/categories/#{id}/children_category",
        success: (data, xhr) =>
          ul.html(data)
          @toggle_tree(li)
      })
    false

  load_table: (li) ->
    id = li.attr("data-value-id")
    $.ajax({
      url: "/system/categories/#{id}/children_table",
      success: (data, xhr) =>
        tbody = @table_el.find("tbody")
        tbody.find(">tr").remove()
        tbody.html(data)
    })
