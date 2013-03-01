class UserSessionsController < ApplicationController
  before_filter :login_required, :only => [ :destroy ]

  respond_to :html

  # omniauth callback method
  def create
    omniauth = env['omniauth.auth']

    logger.debug "+++ #{omniauth}"
    user = User.where(:uid => omniauth['uid']).first
    if not user
      # New user registration
      user = User.new(:uid => omniauth['uid'])
      user.login = omniauth["info"]["login"]
      user.save

    end

    #p omniauth
    # Currently storing all the info
    session[:omniauth] = omniauth

    flash[:notice] = t(:successfully_login, "Successfully logged in")
    redirect_to root_path
  end

  # Omniauth failure callback
  def failure
    flash[:notice] = params[:message]

  end

  # logout - Clear our rack session BUT essentially redirect to the provider
  # to clean up the Devise session from there too !
  def destroy
    session.destroy
    flash[:notice] = 'You have successfully signed out!'
    redirect_to "#{accounts_provider_url}/accounts/logout?redirect_uri=http://#{request.env['HTTP_HOST']}"
  end
end
