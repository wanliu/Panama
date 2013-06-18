class CategoryInput < Formtastic::Inputs::StringInput

  def to_html
    # debugger
    @category_root = Category.where(:name => "_products_root")[0]

    input_wrapping do


    end
  end
end
