#encoding: utf-8

class Admins::Shops::AcountsController < Admins::Shops::SectionController

  def bill_detail
    @people = current_user
    @transfer_moneys = @people.transfer_moneys.order("created_at desc").page(params[:page])
  end

  def shop_info
    @user_checking = current_shop.user.user_checking
    @shop = Shop.find_by(:name => params[:shop_id])
    @shop_auth = ShopAuth.new(@user_checking.attributes)
  end

  def apply_update
    @user_checking = current_shop.user.user_checking
    @shop = Shop.find_by(:name => params[:shop_id])
    @shop_auth = ShopAuth.new(@user_checking.attributes.merge!(:shop_name => @shop.name,:shop_summary => @shop.shop_summary))
    @shop.shutdown_shop
  end

  def edit_address
    @address = current_shop.user.user_checking.address || Address.new
    render layout: false
  end

  def update_address
    @address = current_shop.user.user_checking.address
    @address.update_attributes(params[:address])
    if @address.valid?
      render json: { id: @address.id, address: @address.address_only }
    else
      render json: draw_errors_message(@address), :status => 403
    end
  end

  def create_address
    @address = Address.new(params[:address])
    if @address.save
      render json: { id: @address.id, address: @address.address_only }
    else
      render json: draw_errors_message(@address), :status => 403
    end
  end
end