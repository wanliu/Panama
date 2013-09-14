class CategoryController < ApplicationController
	layout "category"

	before_filter :login_and_service_required, except: :products
	before_filter :login_required, only: :products

	def index
		@category = Category.root
		# @products = Product.joins(:shop_products).where("shop_products.deleted_at is NULL")

		# @products = @products.offset(params[:offset]) if params[:offset].present?
		# @products = @products.limit(params[:limit]) if params[:limit].present?

		respond_to do |format|
			format.html
			# format.json { render json: @products.as_json(
			# 	:methods => :photo_avatar,
			# 	:version_name => "240x240") }
		end
	end

	def show
		@category = Category.find(params[:id])
		# @shop_products = ShopProduct.search2("category.id:#{@category.id}").results
	end

	def shop_products
		@category = if params[:id].blank?
			Category.root
		else
			Category.find(params[:id])
		end
		@shop_products = ShopProduct.joins(:product).joins(:shop).where(
			"products.category_id" => @category.descendants.pluck(:id))
		@shop_products = @shop_products.offset(params[:offset]) if params[:offset].present?
		@shop_products = @shop_products.limit(params[:limit]) if params[:limit].present?

		respond_to do |format|
			format.html
			format.json { render json: @shop_products.as_json(:version_name => "240x240") }
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
