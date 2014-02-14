class CartWidget < CommonWidget
  include CartHelper
  helper CartHelper

  def display
    @my_cart = my_cart
    @my_likes = my_likes
    render
  end

end
