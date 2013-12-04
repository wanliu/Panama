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
    @shop_products = current_user.shop.products
    category_id, product_ids  = @category.id , @shop_products.pluck(:product_id)
    _offset, _limit = params[:offset], params[:limit]
    @products = Product.search2 do
      size _limit
      from _offset
      query do
        boolean do
          must do
            filtered do
              filter :term, :category_id => category_id
            end
          end
          must_not do
            filtered do
              filter :terms, :id => product_ids
            end
          end
        end
      end
    end.results

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
