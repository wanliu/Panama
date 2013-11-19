# encoding : utf-8
class UserCheckingsController < ApplicationController
  before_filter :login_required

  def update_user_auth
  	@user_checking = current_user.user_checking
  	@user_auth = params[:user_auth]
  	@user_checking.update_attributes(@user_auth)
	  redirect_to person_path(current_user)
  end

  def update_shop_auth
    shop_auth_params = params[:shop_auth]
  	@user_checking = current_user.user_checking
    @shop = current_user.shop
    @shop.update_attributes(shop_auth_params[:shop])
    shop_auth_params.delete(:shop)
    @user_checking.update_attributes(shop_auth_params)
    @user_checking.unchecked
  	redirect_to "/shops/#{ @shop.name }/admins/shop_info"
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