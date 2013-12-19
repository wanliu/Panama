# encoding : utf-8
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
    @followings = current_user.followings.users.as_json
    respond_to do |format|
      format.json{ render :json => @followings }
    end
  end

  def channels
    @channels = current_user.persistent_channels.map do |c| {
      login: c.name,
      icon: c.icon,
      follow_type: c.channel_type }
    end
    respond_to do |format|
      format.json{ render :json => @channels }
    end

  end

  def chat_authorization
    auth = User.chat_authorization(params[:from], params[:invested])
    respond_to do |format|
      format.json { render :json => auth }
    end
  end

  #上传头像
  def upload_avatar
    field_name = params[:field_name]
    file = params[:file].is_a?(ActionDispatch::Http::UploadedFile) ? params[:file] : params[field_name]

    unless file.nil?
      @user_photo = User.find(params[:id]).photo
      if @user_photo.send(field_name)
        @user_photo.send(field_name).remove!
      end
      @user_photo.send("#{field_name}=", file)
      if @user_photo.save
        render :text => "{success: true, avatar_filename: '#{@user_photo.send(field_name)}'}"
      else
        render :text => "{success: false, error: '上传头像失败！'}"
      end
    else
      render :text => "{success: false, error: '请上传头像！'}"
    end
  end
end