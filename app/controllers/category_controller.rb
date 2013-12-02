class CategoryController < ApplicationController
  before_filter :login_and_service_required, except: :products
  before_filter :login_required, only: :products

  layout "application"


  def index
    @category = Category.root
    respond_to do |format|
      format.html
    end
  end

  def show
    @category = Category.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def shop_products
    @category = params[:id].blank? ? Category.root : Category.find(params[:id])
    category_ids = @category.descendants.pluck(:id) + [@category.id]
    @shop_products = ShopProduct.joins(:product).joins(:shop).where(
      "products.category_id" => category_ids)
    @shop_products = @shop_products.offset(params[:offset]) if params[:offset].present?
    @shop_products = @shop_products.limit(params[:limit]) if params[:limit].present?

    respond_to do |format|
      format.html
      format.json { render json: @shop_products.as_json(
        :include => "photos") }
    end
  end

  def products
    @category = Category.find(params[:id])
    @shop_products = Shop.find(params[:shop_id]).products
    if @shop_products.present?
      @products = Product.where("category_id =? and id not in (?)", @category.id ,@shop_products.map{|s| s.product_id})
    else
      @products = Product.where("category_id =? ", @category.id )
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  def subtree_ids
    @category_ids = Category.find(params[:id]).subtree_ids
    respond_to do |format|
      format.html
      format.json { render json: @category_ids }
    end
  end
end
