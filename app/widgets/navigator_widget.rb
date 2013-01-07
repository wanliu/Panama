class NavigatorWidget < Apotomo::Widget

  def display
    @navigator = options[:shop].category.children
    render
  end

  def edit
    render
  end

end
