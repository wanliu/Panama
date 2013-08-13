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
    @shop_products = Shop.find(params[:shop_id]).shop_products
    if @shop_products.present?
      @products = Product.where("category_id in (?) and id not in (?)", @category.descendants.map { |c| c.id },@shop_products.map{|s| s.product_id})
    else
      @products = Product.where("category_id in (?) ", @category.descendants.map { |c| c.id })
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

end
