class People::CartController < People::BaseController

  skip_before_filter :identity, :only => [:add_to_cart, :clear_list]

  def index
    @items = ProductItem.where(:cart_id => my_cart.id).page params[:page]
  end

  def add_to_cart
    authorize! :create, Cart
    @item = my_cart.add_to(params[:product_item])
    if @item.save
      render :json => @item.as_json.merge(:img_path => @item.photos.icon)
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def clear_list
    authorize! :destroy, Cart
    my_cart.items.destroy_all
    render :text => :ok
  end

  def move_out_cart    
    @item = my_cart.items.find(params[:id])
    @item.destroy
    render :js => "location.href='/people/#{current_user.login}/cart'"
  end

  def change_number
    @item = my_cart.items.find(params[:id])
    @item.amount = params[:amount]
    @item.total = @item.price * @item.amount
    @item.save
    respond_to do |format|
      format.json{ head :no_content }
    end
  end
end
