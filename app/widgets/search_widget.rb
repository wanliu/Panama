class SearchWidget < Apotomo::Widget

  def display(name, default = nil, html_options = {})
    @name = name
    @default = default
    @html_options = html_options
    render
  end

  def click
    
  end
end
