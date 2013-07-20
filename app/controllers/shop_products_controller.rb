class ShopProductsController < ApplicationController
	def index
		@shop = Shop.find(params[:shop_id])
		@products = @shop.shop_products
		respond_to do |format|
			format.json { render json: @products }
		end
	end

	def create
		if current_user.shop
			@shop_product = current_user.shop.shop_products.create(product_id: params[:product_id],
																												     price: 0,
																												     inventory: 1)
			respond_to do |format|
				if @shop_product.valid?
					product = @shop_product.product
					result  = { id: @shop_product.id, name: product.name,
							    price: @shop_product.price, inventory: @shop_product.inventory }
					format.json { render json: result }
				else
					format.json { render json: @shop_product.errors, status: :unprocessable_entity }
				end
			end
		else
			respond_to do |format|
				format.json { render json: { error: "请返回上一步建立商店信息" }, status: :unprocessable_entity }
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