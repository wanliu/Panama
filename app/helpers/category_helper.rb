module CategoryHelper

  def tree_cls_name(c, last)
    cls_name = "expandable" if c.children.length > 0
    last_name = "last#{cls_name.to_s.camelcase}" if c == last

    unless cls_name.nil?
      hitarea_name = "#{last_name}-hitarea" unless last_name.nil?
      hitarea_name = "#{cls_name}-hitarea #{hitarea_name}"
    end

    ["#{cls_name} #{last_name}", hitarea_name]
  end

  def root_category_tree
    html = ""
    root = (Category.root.children.size == 1 ? Category.root.children[0] : Category.root)
    root.children.each do |category|
      html << lv1_category_tree_of(category)
    end
    html.html_safe
  end

  def lv1_category_tree_of(category)
    li_begin_of(category) << descendant_categories_html(category) << li_end_of(category)
  end

  def lv2_category_tree_of(category)
    html = "<li class='lv2_category_tree'>
              <a href='/category/#{category.id}' data-category_id='#{ category.id }'>
                <span>#{ category.name }</span>
              </a>
              <ul>"
    category.children.each do |child|
      html << "<li class='lv3_category_node'>
          <a href='/category/#{category.id}' data-category_id='#{ category.id }'>
            #{ child.name }
          </a>
        </li>"
    end
    html << "</ul></li>"
  end

  def li_begin_of(category)
      "<li class='accordion-group'>
        <a class='accordion-toggle collapsed' data-toggle='collapse' data-parent='#forms-collapse-#{ category.parent.id }' href='#forms-collapse-#{ category.id }'>
          <i class='icon-caret-right'></i>
          <span>#{ category.name }</span>
        </a>"
  end

  def descendant_categories_html(category)
    html = ""
    if category.children.size > 0
        html << "<ul id='forms-collapse-#{ category.id }' class='collapse lv2_categories'>"
          category.children.each do |child|
            html << lv2_category_tree_of(child)
          end
        html << "</ul>"
      HTML
    end
    html
  end

  def li_end_of(category)
    "</li>"
  end
end
