class People::CartController < People::BaseController
  def index
    @items = ProductItem.where(:cart_id => my_cart.id).page params[:page]
  end

  def add_to_cart
    param = params[:product_item]
    @product_obj = my_cart.items.find_by_product_id(param[:product_id])
    if @product_obj
      @item = items_update @product_obj,param
    else
      @item = items_build param
    end
    items = item_as_json @item
    render :json => items
  end

  def items_update(product_obj,param) 
    product_obj.update_attributes({:amount => product_obj.amount + param[:amount].to_i, 
                                   :total => product_obj.price * product_obj.amount})
    product_obj
  end

  def items_build(param)
    @item = my_cart.items.build(param)
    total = @item.price * @item.amount
    @item.total = total
    @item.save
    my_cart.save
    @item
  end

  def item_as_json(items)
    item = items.as_json()
    img_url = items.product ? items.product.photos.icon : ""
    item["product_item"]["img"] = img_url
    item
  end

  def clear_list
    my_cart.items.delete_all
    render :text => :ok
  end
end
