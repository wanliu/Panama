class SystemSessionsController < ApplicationController
  before_filter :admin_required, :only => [ :destroy ]

  respond_to :html

  # omniauth callback method
  def create
    omniauth = env['omniauth.auth']

    logger.debug "+++ #{omniauth}"
    admin = AdminUser.where(:uid => omniauth['uid']).first
    if not admin
      # New user registration
      admin = AdminUser.new(:uid => omniauth['uid'])
      admin.login = omniauth["info"]["login"]
      admin.save

    end

    #p omniauth
    # Currently storing all the info
    session[:admin_id] = omniauth['uid']

    flash[:notice] = t(:admin_successfully_login, "Successfully logged in")
    redirect_to system_root_path
  end

  # Omniauth failure callback
  def failure
    flash[:notice] = params[:message]

  end

  # logout - Clear our rack session BUT essentially redirect to the provider
  # to clean up the Devise session from there too !
  def destroy
    session[:admin_id] = nil

    flash[:notice] = 'You have successfully signed out!'
    redirect_to "#{accounts_provider_url}/system/logout?callback_redirect_uri=http://#{request.env['HTTP_HOST']}"
  end
end
