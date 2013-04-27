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

end