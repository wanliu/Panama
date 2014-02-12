class People::CartController < People::BaseController

  skip_before_filter :identity, :only => [:add_to_cart, :clear_list]

  def index
    @items = ProductItem.where(:cart_id => my_cart.id).page params[:page]
    @quantity_total = my_cart.items.sum(:amount)
    @price_total = my_cart.items.sum(:total).to_f
  end

  def add_to_cart
    authorize! :create, Cart
    @shop_product = ShopProduct.find(params[:shop_product_id])
    @item = my_cart.add_to(params[:product_item].merge({
      :product_id => @shop_product.product_id,
      :shop_id => @shop_product.shop_id,
      :title => @shop_product.product.name,
      :price => @shop_product.price,
      :user_id => current_user.id
    }))
    if @item.save
      render :json => @item.as_json.merge(:img_path => @item.photos.icon)
    else
      render json: draw_errors_message(@item), status: 403
    end
  end

  def clear_list
    authorize! :destroy, Cart
    my_cart.items.destroy_all
    respond_to do |format|
      format.html { redirect_to person_cart_index_path(current_user.login) }
      format.js { head :no_content }
    # render :text => :ok
    end
  end

  def move_out
    item_ids = params[:item_ids]
    my_cart.items.where("id in (?)", item_ids).destroy_all
    render :json => { text: 'ok' }
  end

  def move_out_cart
    @item = my_cart.items.find(params[:id])
    @item.destroy
    render :js => "location.href='/people/#{current_user.login}/cart'"
  end

  def change_number
    item = my_cart.items.find(params[:id])
    item.amount = params[:amount]
    item.total = item.price * item.amount   

    respond_to do |format|
      if item.save
        cart_amount = my_cart.items.sum(:amount)
        cart_total = my_cart.items.sum(:total).to_f
        format.json { render json: item.as_json.merge(
        cart: {amount: cart_amount, total: cart_total})  }
      else
        format.json{ render :json => draw_errors_message(item), :status => 403 }
      end
    end
  end
end
