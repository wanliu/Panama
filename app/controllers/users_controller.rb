class UsersController < ApplicationController

  def index
    users = User.where("login like ?", "%#{params[:q]}").select(:login)
    respond_to do |format|
      format.json { render :json => users.map{|u| {login: u.login} } }
    end
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.json{ render :json => @user }
    end
  end

  def connect
    @user = User.find_by(:im_token => params[:token])
    @user.connect
    respond_to do |format|
      format.json{ render :json => @user }
    end
  end

  def followings
    followings = current_user.format_followings
    respond_to do |format|
      format.json{ render :json => followings }
    end
  end
end