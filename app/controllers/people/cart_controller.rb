class People::CartController < People::BaseController
  def index
    @items = ProductItem.where(:cart_id => my_cart.id).page params[:page]
  end

  def add_to_cart
    param = params[:product_item]
    product_obj = my_cart.items.find_by_product_id(param[:product_id])
    if product_obj
      @item = items_update product_obj,param
    else
      @item = items_build param
    end
    item = item_as_json @item
    render :json => item
  end

  def items_update(product_obj,param)
    product_obj.amount = product_obj.amount + param[:amount].to_i
    product_obj.total = product_obj.price * product_obj.amount
    product_obj.save
    my_cart.save
    product_obj
  end

  def items_build(param)
    @item = my_cart.items.build(param)
    @item.total = @item.price * @item.amount
    @item.save
    my_cart.save
    @item
  end

  def item_as_json(items)
    item = items.as_json()
    item["product_item"]["img"] = items.product.photos.icon
    item
  end

  def clear_list
    my_cart.items.delete_all
    render :text => :ok
  end
end
