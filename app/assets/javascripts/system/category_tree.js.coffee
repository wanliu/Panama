# 分类树

root = (window || @)

class root.CategoryTree

  constructor: (options) ->
    $.extend(@, options)
    @el.on("click", "li.expandable", $.proxy(@load_tree, @))
    @el.on("click", "li.collapsable", $.proxy(@load_tree, @))
    @el.on("click", "li", (event) =>
      li = $(event.currentTarget)
      @load_table(li)
      return false
    )
    #@el.find(">li").click()

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
    li = $(event.currentTarget);
    ul = li.find(">ul");
    if ul.find(">li").length <= 0
      id = li.attr("data-value-id");
      $.ajax({
        url: "/system/categories/#{id}/children_category",
        success: (data, xhr) =>
          ul.html(data);
          @toggle_tree(li);
      })
    else
      @toggle_tree(li)

    false

  load_table: (li) ->
    id = li.attr("data-value-id");
    $.ajax({
      url: "/system/categories/#{id}/children_table",
      success: (data, xhr) =>
        tbody = @table_el.find("tbody")
        tbody.find(">tr").remove();
        tbody.html(data)

    })
