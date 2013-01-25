class People::CartController < ApplicationController
  layout "cart"

  def index
  end

  def add_to_cart
    @item = my_cart.items.build(params[:product_item])
    @item.total = @item.price * @item.amount
    @item.save
    my_cart.save
    render :json => @item
  end

  def clear_list
    my_cart.items.delete_all
    render :text => :ok
  end
end
