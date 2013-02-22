class ProductsController < ApplicationController

  layout "product"

  def show
    @product = Product.find(params[:id])
    @item = ProductItem.new(:product_id => @product, 
                            :title => @product.name,
                            :price => @product.price, 
                            :amount => 1)
  end
end
