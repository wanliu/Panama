# encoding: utf-8
class ShopProductsController < ApplicationController
	before_filter :login_required
  before_filter :login_and_service_required, only: :buy

	def index
	    @shop = Shop.find(params[:shop_id])
	    @products = @shop.shop_products
	    respond_to do |format|
	      format.json { render json: @products }
	    end
	end

  def create
    if current_user.shop.present?
      product_ids   = params[:product_ids]
      shop_products = product_ids.map do |product_id|
        current_user.shop.shop_products.create(
          product_id: product_id,
          price: 0,
          inventory: 1
        )
      end
      valid_shop_products = shop_products.find { |product| product.valid? }

      respond_to do |format|
        if !valid_shop_products.blank?
          format.json { render json: shop_products }
        else
          format.json { render json: { errors: "无法创建商店商品" },
                     status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.json { render json: { error: "请先建立商店信息" },
                   status: :unprocessable_entity }
      end
    end
  end

  def update
    @product = ShopProduct.find(params[:id])
    respond_to do |format|
      if @product.update_attributes(params[:shop_product])
        format.json { render json: @product }
      else
        format.json { render json: @product.errors,
                   status: :unprocessable_entity }
      end
    end
  end

  def show
    @shop_product = ShopProduct.find(params[:id])
    @product_comments = ProductComment.where("product_id=? and shop_id=?", @shop_product.product_id, @shop_product.shop.id)
    respond_to do |format|
      format.html # show.html.erb
      format.dialog { render "show.dialog", :layout => false }
      format.json { render json: @shop_product.as_json.merge(
        product: @shop_product.product.as_json(
          version_name: params[:version_name])) }
    end
  end

  def buy
    @shop_product = ShopProduct.find(params[:id])
    respond_to do |format|
      @order = current_user.transactions.build(seller_id: @shop_product.shop_id)
      @order.items.build({
        :product_id => @shop_product.product_id,
        :amount => params[:amount],
        :title => @shop_product.product.try(:name),
        :price => @shop_product.price,
        :user_id => current_user.id,
        :shop_id => @shop_product.shop_id,
        :buy_state => :guarantee
      })
      if @order.save
        format.json{ render :json => @order }
      else
        format.json{ render :json => draw_errors_message(@order), :status => 403 }
      end
    end
  end

  def direct_buy
    @shop_product = ShopProduct.find(params[:id])
    respond_to do |format|
      @order = current_user.direct_transactions.build(seller_id: @shop_product.shop_id)
      @order.items.build({
        :product_id => @shop_product.product_id,
        :amount => params[:amount],
        :title => @shop_product.product.try(:name),
        :price => @shop_product.price,
        :user_id => current_user.id,
        :shop_id =>  @shop_product.shop_id,
        :buy_state => :direct
      })
      if @order.save
        format.json{ render :json => @order }
      else
        format.json{ render :json => draw_errors_message(@order), :status => 403 }
      end
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