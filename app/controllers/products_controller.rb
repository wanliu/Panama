class ProductsController < ApplicationController

  layout "product"
  
  def show
    @product = Product.find(params[:id])
  end
end
