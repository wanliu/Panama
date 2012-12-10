class SearchWidget < Apotomo::Widget

  def display(name)
    render locals: { name: name }
  end

end
