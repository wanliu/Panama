class UserCheckingsController < ApplicationController
  before_filter :login_required

  def update_user_auth
  	@user_checking = current_user.user_checking
  	@user_auth = params[:user_auth]
  	@user_checking.update_attributes(@user_auth)
	redirect_to person_path(current_user)
  end

  def update_shop_auth
  	@user_checking = current_user.user_checking
  	@shop_auth = params[:shop_auth]
  	@user_checking.update_attributes(@shop_auth)
  	redirect_to "/shops/#{ @user_checking.user.login }/admins/shop_info"
  end
end