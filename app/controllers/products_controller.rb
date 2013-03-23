class ProductsController < ApplicationController
  before_filter :login_required

  layout "product"

  def show
    @product = Product.find(params[:id])
    @product_sale_option = Content.fetch_for(@product, :sale_options)
    @item = ProductItem.new(# :product_id => @product,
                            :title => @product.name,
                            :price => @product.price,
                            :amount => 1)
  end
end
