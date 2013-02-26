class People::CartController < People::BaseController
  def index
    @items = ProductItem.where(:cart_id => my_cart.id).page params[:page]
  end

  def add_to_cart
    @product = my_cart.items.find_by_product_id(params[:product_id])

    item = my_cart.add_to(params[:product_item])
    if item.save
      render :json => item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def clear_list
    my_cart.items.delete_all
    render :text => :ok
  end
end
