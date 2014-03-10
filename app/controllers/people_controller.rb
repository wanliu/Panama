#encoding: utf-8
class PeopleController < ApplicationController
  before_filter :login_and_service_required, :except => [:show_email_invite]

  layout "people"

  def photos
    user = User.find_by(:login => params[:login])
    respond_to do |format|
      format.json { 
        render :json => { :icon => user.try(:photos).try(:icon) } 
      }
    end
  end

  def show
    @people = User.find_by(:login => params[:id])
    @transfer_moneys = @people.transfer_moneys.order("created_at desc").page(params[:page])
    current_ability(@people)
  end

  def edit
    @user_checking = current_user.user_checking
    @user_auth = UserAuth.new(@user_checking.attributes)
    @people = User.find_by(:login => params[:id])
    current_ability(@people)
    authorize! :manage, User
  end

  def update_user_auth
    @people = User.where(:login => params[:login]).first
    current_ability(@people)
    authorize! :manage, User
    @user_checking = @people.user_checking
    @user_auth = UserAuth.new(params[:user_auth])
    if @user_auth.valid?
      @user_checking.update_attributes(params[:user_auth])
      redirect_to person_path(current_user)
    else
      render "edit"
    end
  end

  def update_email
    @people = current_user
    @people.email = params[:email]
    respond_to do |format|
      if @people.save
        format.json{ render :json => @people }
      else
        format.json{ render :json => draw_errors_message(@people), :status => 403 }
      end
    end
  end

  def show_email_invite
    @people = User.find_by(:login => current_user.login)
    if valid_invite_options(decrypt_options)
      @invite = @shop.invites.create(          
        :send_user => @send_user,
        :user => current_user,
        :body => "商店 #{@shop.name} 邀请你加入")
      if @invite.valid?
        redirect_to person_invite_path(current_user, @invite)
      else
        @error_messages = draw_errors_message(@invite).join("<br />")
        render_error
      end
    end
  end

  def all_circles
    @user = User.find_by(:login => params[:id])
    @circles = @user.shop.all_type_circles
    render "/people/communities/all_circles", :layout => false    
  end

  # 关注
  def follow
    this_person = User.find_by(:login => params[:id])
    follow = Following.new(:user => current_user, :follow => this_person)
    unless Following.is_exist?(follow)
      follow.save
    end
    redirect_to :action => 'show'
  end

  # 取消关注
  def unfollow
    this_person = User.find_by(:login => params[:id])
    Following.delete_all(["user_id = ? and follow_id = ? and follow_type = 'User'", current_user.id, this_person.id])
    redirect_to :action => 'show'
  end

  private
  def current_ability(people = nil)
    @current_ability ||= PeopleAbility.new(current_user, people)
  end

  def decrypt_options
    {
      :auth => params[:auth],
      :shop_name => (Crypto.decrypt(params[:shop_name]) rescue nil),
      :send_user_id => (Crypto.decrypt(params[:send_user]) rescue nil)
    }
  end

  def valid_invite_options(options)
    @shop = Shop.find_by(:name => options[:shop_name])
    now = validate_auth_string(options[:auth])
    current_ability(current_user)
    @send_user = User.find_by(:id => options[:send_user_id])
    @error_messages = if !now
      "无效的邀请信息"
    elsif now+3.day < DateTime.now
      "邀请信息已经过期！"
    elsif @shop.nil?
      "商店不存在"
    end
    render_error
  end

  def render_error
    if @error_messages
      render template: "errors/errors_403", status: 403, layout: "error"
      return false
    end
    return true
  end
end
