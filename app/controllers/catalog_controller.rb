class CatalogController < ApplicationController
	
	def index
    	@catalogs = Catalog.all
    	respond_to do |format|
    		format.html
    		format.json{ render json: @catalogs }
    	end	
	end

	def show
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
			format.json { render json: @shop_products.as_json(:version_name => "240x240") }
		end
	end
end
