class CategoryInput < Formtastic::Inputs::StringInput

  def to_html
    # debugger
    @category_root = Category.where(:name => "_products_root")[0]

    input_wrapping do

      label_html << builder.hidden_field(method, input_html_options) + @template.build_menu(@category_root)

      # builder.text_field(method, input_html_options)
    end
  end
end
