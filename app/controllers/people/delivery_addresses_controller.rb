# coding: utf-8
class People::DeliveryAddressesController < People::BaseController

  def index
    @addresses = DeliveryAddress.where(:user_id => @people.id)
  end

  def new
    @address = DeliveryAddress.new
  end

  def edit    
    @address = current_user_address(params[:id])
    render layout: false
  end

  def create
    @address = @people.delivery_addresses.build(params[:delivery_address])
    respond_to do |format|
      if @address.save
        flash[:success] = "添加成功！"
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@address), :status => 403 }
      end
    end
  end

  def update
    @address = current_user_address(params[:id])
    respond_to do |format|
      if @address.update_attributes(params[:delivery_address])
        flash[:success] = "修改收货地址成功！"
        format.json{ head :no_content }
      else
        format.json{ render :json => draw_errors_message(@address), :status => 403 }
      end
    end
  end

  def destroy
    current_user_address(params[:id]).destroy
    flash[:success] = "删除收货地址成功！"
    redirect_to person_delivery_addresses_path
  end

  private 
  def current_user_address(id)
    @people.delivery_addresses.find(id)
  end
end