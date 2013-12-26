# encoding: utf-8
class ShopProductsController < ApplicationController
  before_filter :login_required
  before_filter :login_and_service_required, only: :buy

  def index
    @shop = Shop.find(params[:q][:shop_id])
    @products = @shop.products.includes(:product)
    @products = @products.offset(params[:offset]) if params[:offset].present?
    @products = @products.limit(params[:limit]) if params[:limit].present?

    respond_to do |format|
      format.json { render json: @products.as_json(
        :includes => :shop) }
    end
  end

  def create
    if current_user.shop.present?
      product_ids   = params[:product_ids] || []
      shop_products = product_ids.map do |product_id|
        current_user.shop.products.create(
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

  def update_attribute
    params[:shop_product] = { params.delete(:name) => params.delete(:value) }
    update
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
      @item = @order.items.build({
        :product_id => @shop_product.product_id,
        :amount => params[:amount],
        :title => @shop_product.product.try(:name),
        :price => @shop_product.price,
        :user_id => current_user.id,
        :shop_id => @shop_product.shop_id
      })
      @item.buy_state = :guarantee
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
      @item = @order.items.build({
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
        format.json{
          _errors = draw_errors_message(@order) + draw_errors_message(@item)
          render :json => _errors, :status => 403 }
      end
    end
  end

  def destroy
    @product = ShopProduct.find(params[:id])
    # ShopProduct.tire.index.remove @product  #this will remove them from the index
    @product.destroy

    respond_to do |format|
      format.json{ head :no_content }
    end
  end

  def delete_many
    product_ids = params[:product_ids]
    # product_ids.each do |product_id|
    #   @product = ShopProduct.find(product_id)
    #   ShopProduct.tire.index.remove @product
    # end
    ShopProduct.where("id in (?)",product_ids).destroy_all

    respond_to do |format|
      format.json{ head :no_content }
    end
  end

  def search
    shop_id, value = params[:shop_id], filter_special_sym(params[:q])
    _size, _from = params[:limit] || 10, params[:offset] || 0
    products = ShopProduct.search2 do
      query do
        boolean do
          must do
            filtered do
              if value.present?
              filter :query, :query_string =>{
                  :query => "name:#{value} OR primitive:#{value} OR untouched:#{value}*",
                  :default_operator => "AND"
                }
              end
              filter :term, "seller.id" => shop_id
            end
          end
        end
      end
      size _size
      from _from
    end.results
    respond_to do |format|
      format.json{ render :json => products }
    end
  end
end