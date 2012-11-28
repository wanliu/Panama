class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user

  def login_required
    if !current_user
      respond_to do |format|
        format.html  {
          redirect_to '/auth/wanliuid'
        }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json
        }
      end
    end
  end

  def current_user
    return nil unless session[:user_id]
    @current_user ||= User.where(:uid => session[:user_id]['uid']).first
  end
end
