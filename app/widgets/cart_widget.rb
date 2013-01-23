class CartWidget < CommonWidget

  def display
    @my_cart = my_cart
    render
  end

end
