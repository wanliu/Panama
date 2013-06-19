#encoding: utf-8
class CategoryInput < Formtastic::Inputs::StringInput

  def to_html
    input_wrapping do
      label_html << builder.hidden_field(method, input_html_options.merge(name: "proudct[category_id]")) << mock_input << generate_ul_tree
    end
  end

  def root
    input_options[:root] || Category.where(:name => "_products_root")[0]
  end

  def mock_input
    "<input type='text' class='mock_prodcut_category_id' value='未选择' readonly>".html_safe
  end

  def generate_ul_tree
    template.content_tag :div, :class => tree_parent_class do
      template.build_menu(root)
    end
  end

  def tree_parent_class
    input_html_options[:tree_parent_class] || 'category-parent-class'
  end
end
