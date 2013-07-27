# encoding: utf-8
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
			product_ids = params[:product_ids]
			shop_products = []
			product_ids.map {| product_id | 
				shop_products << current_user.shop.shop_products.create(
					product_id: product_id,
					price: 0,
					inventory: 1
				)
			}																								   
			respond_to do |format|
				if shop_products.any? {|product| product.valid? }
					valid_shop_products = shop_products.find {|product| product.valid? }
					# @product = @shop_product.product
					# result  = { id: @shop_product.id, name: product.name,
					# 		    price: @shop_product.price, inventory: @shop_product.inventory, photos: product.photos }
					format.json { render json: shop_products }
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
			if @product.update_attributes(params[:shop_product])
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

	def destroy
		@product = ShopProduct.find(params[:id])
		@product.destroy

		respond_to do |format|
			format.json{ head :no_content }
		end
	end
end