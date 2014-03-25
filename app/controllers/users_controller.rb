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

  def get_token
    require 'net/http'  

    @user = User.where(login: params[:login]).first
    puts "========= #{@user.login} =============="
    if (@user.blank?)
      respond_to do |format|
        format.json { render :json => { token: nil } }
      end
    else
      caramal_app_id = Settings.caramal_api_token
      caramal_host   = Settings.caramal_api_server

      begin
        url = get_user_token_url(caramal_host, caramal_app_id, @user)
        puts ">>>>>> #{url} <<<<<<<<<<"
        url_str = URI.parse(url)
        site = Net::HTTP.new(url_str.host, url_str.port)
        site.open_timeout = 0.2
        site.read_timeout = 0.2
        path = url_str.query.blank? ? url_str.path : url_str.path + "?" + url_str.query
        response = site.get2(path, {'accept'=>'text/json'})
        response = JSON.parse(response.body)
        puts "======== #{response} ========"
      rescue Exception => ex
        puts "Error: #{ex}"
        response = {}
      end

      token = response['token']

      respond_to do |format|
        format.json { render :json => { token: token } }
      end
    end
  end

  def followings
    @followings = current_user.followings.users.as_json
    respond_to do |format|
      format.json{ render :json => @followings }
    end
  end

  def channels
    channels = current_user.chat_channels
    respond_to do |format|
      format.json{ render :json => channels }
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

  protected
  def get_user_token_url(caramal_host, caramal_app_id, user)
    "#{caramal_host}/api/#{caramal_app_id}/user_token/#{user.login}"
  end
end