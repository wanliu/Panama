class ShopProductsController < ApplicationController
	def index
		@shop = Shop.find(params[:shop_id])
		@products = @shop.shop_products
		respond_to do |format|
			format.json { render json: @products }
		end
	end

	def create
		@product = ShopProduct.create(params[:shop_product])
		respond_to do |format|
			if @product.valid?
				format.json { render json: @product }
			else
				format.json { render json: @product.errors, status: :unprocessable_entity }
			end
		end
	end

	def update
		@product = ShopProduct.find(params[:id])
		respond_to do |format|
			if @preduct.update_attributes(params[:shop_product])
				format.json { render json: @product }
			else
				format.json { render json: @product.errors, status: :unprocessable_entity }
			end
		end
	end

	def show
		@product = ShopProduct.find(params[:id])
		respond_to do |format|
			format.json { render json: @product }
		end
	end
end