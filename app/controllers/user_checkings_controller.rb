# encoding : utf-8
class UserCheckingsController < ApplicationController
  before_filter :login_required

  def update_shop_auth
    @current_shop = Shop.find(params[:shop_id])
    @user_checking = @current_shop.user.user_checking
    @shop_auth = ShopAuth.new(params[:shop_auth].merge!(:user_id => @current_shop.user.id))
    @shop_auth.get_validate_params(@current_shop.id, @user_checking.id)
    respond_to do |format|
      if @shop_auth.valid?
        @current_shop.update_attributes(:name => @shop_auth.shop_name, :shop_summary => @shop_auth.shop_summary)
        @user_checking.update_attributes(@shop_auth.to_param)
        @user_checking.unchecked
        format.json{ render :json => @shop_auth }
      else
        format.json{ render :json => draw_errors_message(@shop_auth), :status => 403 }
      end
    end
  end

  def upload_shop_photo(file)
    if @user_checking.user.shop.nil?
      @user_checking.user.create_shop()
    end
    @user_checking.user.shop.photo = file
    @user_checking.user.shop.save!
  end

  #上传头像
  def upload_photo   
    field_name = params[:field_name]
    file = params[:file].is_a?(ActionDispatch::Http::UploadedFile) ? params[:file] : params[field_name] 
    unless file.nil?
      @user_checking = User.find(params[:id]).user_checking
      if field_name == "photo"
        upload_shop_photo(file)
        render :text => "{success: true, avatar_filename: '#{@user_checking.user.shop.send(field_name)}'}"
        return 
      else 
        @user_checking.send(field_name).remove! if  @user_checking.send(field_name)
        @user_checking.send("#{field_name}=",file)
      end

      if @user_checking.save
        render :text => "{success: true, avatar_filename: '#{@user_checking.send(field_name)}'}"
      else
        render :text => "{success: false, error: '上传头像失败！'}"
      end
    else
      render :text => "{success: false, error: '请上传头像！'}"
    end
  end
end