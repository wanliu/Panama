class ButtonWidget < Apotomo::Widget

  def display(title)
    render locals: { title: title}
  end

end
