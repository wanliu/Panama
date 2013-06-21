class CategoryController < ApplicationController
  layout "category"

  before_filter :login_required

  def index
    @category = Category.where(:name => '_products_root').first
    @products = Product.limit(60)
  end

  def show
    @category = Category.find(params[:id])
    @products = Product.where(:category_id => @category).limit(60)
  end

end
