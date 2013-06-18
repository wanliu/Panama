class CategoryInput < Formtastic::Inputs::StringInput

  def to_html
    input_wrapping do
      label_html << builder.hidden_field(method, input_html_options) << generate_ul_tree
    end
  end

  def root
    input_options[:root] || Category.where(:name => "_products_root")[0]
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
