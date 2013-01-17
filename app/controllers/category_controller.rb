class CategoryController < ApplicationController
  layout "category"

  def index
    @category = Category.where(:name => '_products_root').first
    @products = Product.limit(60)
  end

  def show
    @category = Category.find(params[:id])
    @products = Product.where(:category => @category).limit(60)
  end
end
