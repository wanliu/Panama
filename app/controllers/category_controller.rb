class CategoryController < ApplicationController
  layout "category"

  before_filter :login_and_service_required, except: :products
  before_filter :login_required, only: :products

  def index
    @category = Category.where(:name => '_products_root').first
    @products = Product.page params[:page]
  end

  def show
    @category = Category.find(params[:id])
    @products = Product.where(:category_id => @category).limit(60)    
  end

  def products
    @category = Category.find(params[:id])
    @products = Product.where("category_id in (?)", @category.descendants.map { |c| c.id })

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products.as_json(:only =>[:id,:name])}
    end
  end

end
