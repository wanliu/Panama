class ProductSearchController < ApplicationController
  before_filter :login_required

  def index
    # products = Redis::Search.complete("Product", params[:q]).first(10)
    s = Product.search2 "name:#{params[:q]}"
    products = s.results
    respond_to do |format|
      format.json { render json: products }
    end
  end

  def shop
    if current_user.shop
      query = params[:q]
      shop_id = current_user.shop.id
      s = ShopProduct.search2 do 
        query do
          string "name:#{query}* and seller.id:#{shop_id}"
        end
      end
      products = s.results
    else
      products = []
    end
    respond_to do |format|
      format.json { render json: products }
    end
  end
end