class UserSessionsController < ApplicationController
  # before_filter :login_and_service_required, :only => [ :destroy ]

  respond_to :html

  # omniauth callback method
  def create
    omniauth = env['omniauth.auth']
    logger.debug "+++ #{omniauth}"
    user = User.find_by(:uid => omniauth['uid'])
    if not user
      # New user registration
      user = User.new(:uid => omniauth['uid'])
      user.login = omniauth["info"]["login"]      
      user.photo.filename = omniauth["info"]["avatar"]
    else
      user.photo.filename = omniauth["info"]["avatar"]
    end    
    user.email = omniauth["info"]["email"]
    user.im_token = omniauth["info"]["im_token"]

    user.save

    #p omniauth
    # Currently storing all the info
    session[:user_id] = omniauth['uid']

    flash[:notice] = t(:successfully_login, "Successfully logged in")
    redirect_to auth_redirect
  end

  # Omniauth failure callback
  def failure
    flash[:notice] = params[:message]

  end

  # logout - Clear our rack session BUT essentially redirect to the provider
  # to clean up the Devise session from there too !
  def destroy
    session.destroy if session.present?
    flash[:notice] = 'You have successfully signed out!'
    redirect_to "#{accounts_provider_url}/accounts/logout?redirect_uri=http://#{request.env['HTTP_HOST']}"
  end
end
