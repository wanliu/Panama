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
        @current_shop.shutdown_shop
        format.json{ render :json => @shop_auth }
      else
        format.json{ render :json => draw_errors_message(@shop_auth), :status => 403 }
      end
    end
  end

  #上传头像
  def upload_photo
    field_name = params[:field_name]
    file = params[:file].is_a?(ActionDispatch::Http::UploadedFile) ? params[:file] : params[field_name] 
    unless file.nil?
      @user_checking = User.find(params[:id]).user_checking
      @user_checking.send(field_name).remove! if @user_checking.send(field_name)
      @user_checking.send("#{field_name}=",file)
      if @user_checking.save
        # @shop = @user_checking.user.try(:belongs_shop)
        # update_shop_photo(file) unless @shop.nil?
        render :text => "{success: true, avatar_filename: '#{@user_checking.send(field_name)}'}"
      else
        render :text => "{success: false, error: '上传头像失败！'}"
      end
    else
      render :text => "{success: false, error: '请上传头像！'}"
    end
  end
  # #将userchecking的shop_photo字段同步到shop的photo字段
  # private
  # def update_shop_photo(file)
  #   @current_ability = ShopAbility.new(current_user, @shop)
  #   authorize! :manage, @shop
  #   @shop.photo = @user_checking.shop_photo
  #   @shop.save
  # end
end