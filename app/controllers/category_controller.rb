class CategoryController < ApplicationController
	layout "category"

	before_filter :login_and_service_required, except: :products
	before_filter :login_required, only: :products

	def index
		@category = Category.root
		@products = Product.joins(:shop_products).where("shop_products.deleted_at is NULL")

		@products = @products.offset(params[:offset]) if params[:offset].present?
		@products = @products.limit(params[:limit]) if params[:limit].present?
		
		respond_to do |format|
			format.html
			format.json { render json: @products.as_json(:version_name => "240x240") }
		end
	end

	def show
		@category = Category.find(params[:id])
		@shop_products = ShopProduct.search2("category.id:#{@category.id}").results
	end

	def shop_products
		@category = Category.find(params[:id])
		@products = Product.joins(:shop_products).where("shop_products.deleted_at is NULL and category_id in (?) ", @category.descendants.map { |c| c.id })

		@products = @products.offset(params[:offset]) if params[:offset].present?
		@products = @products.limit(params[:limit]) if params[:limit].present?

		respond_to do |format|
			format.html
			format.json { render json: @products.as_json(:version_name => "240x240") }
		end
	end

	def products
		@category = Category.find(params[:id])
		@shop_products = Shop.find(params[:shop_id]).shop_products
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

end
