class CatalogController < ApplicationController
  layout  "category"
  def index
      @catalogs = Catalog.all
      respond_to do |format|
        format.html
        format.json{ render json: @catalogs }
      end
  end

  def show
    @catalog = Catalog.find(params[:id])
  end

  def products
    catelog = Catalog.find(params[:id])
    @category_ids = []
    catelog.categories.each do |category|
      @category_ids << category.id
    end
    @shop_products = ShopProduct.joins(:product).joins(:shop).where(
      "products.category_id" => @category_ids)
    @shop_products = @shop_products.offset(params[:offset]) if params[:offset].present?
    @shop_products = @shop_products.limit(params[:limit]) if params[:limit].present?

    respond_to do |format|
      format.html
      format.json { render json: @shop_products.as_json(:include => "photos") }
    end
  end

  def children_categories
    ancestry_ids = Catalog.find(params[:id]).categories.pluck("ancestry")
    @categories = Category.descendants(ancestry_ids)
    respond_to do |format|
      format.html
      format.json { render json: @categories }
    end
  end


end
