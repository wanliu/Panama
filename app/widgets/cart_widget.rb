class CartWidget < CommonWidget
  include CartHelper
  helper CartHelper

  def display
    @my_cart = my_cart
    render
  end

end
