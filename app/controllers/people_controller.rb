#encoding: utf-8
class PeopleController < ApplicationController
  before_filter :login_and_service_required

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

  def show_invite
    valid_invite_user
  end

  def agree_invite_user
    if valid_invite_user
      shop_user = @shop.shop_users.create(:user_id => current_user.id)
      respond_to do | format |
        if shop_user.valid?
          shop_user.user.notify("/shops/joined",
                                "你已经成功加入商店 #{@shop.name}",
                              { :avatar => shop_user.user.icon,
                                :url => "/shops/#{@shop.name}" })    
          format.html{ redirect_to person_path(current_user.login) }
        else
          @error_messages = draw_errors_message(shop_user)
          format.html{ render template: "errors/errors_403", status: 403, layout: "error" }
        end
      end
    end
  end

  def agree_email_invite_user
    @people = User.find_by(:login => current_user.login)
    if valid_invite_options(decrypt_options)
      shop_user = @shop.shop_users.create(:user_id => current_user.id)
      respond_to do | format |
        if shop_user.valid?
          shop_user.notify("/shops/joined",
                           "你已经成功加入商店 #{@shop.name}",
                           { :avatar => shop_user.user.icon,
                             :url => "/shops/#{@shop.name}" })  
          format.html{ redirect_to person_path(current_user.login) }
        else
          @error_messages = draw_errors_message(shop_user)
          format.html{ render template: "errors/errors_403", status: 403, layout: "error" }
        end
      end
    end
  end

  def show_email_invite
    @people = User.find_by(:login => current_user.login)
    if valid_invite_options(decrypt_options)
      render :action => :show_invite
    end
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
      :login => (Crypto.decrypt(params[:login]) rescue nil)
    }
  end

  def valid_invite_user
    options = decrypt_options
    if valid_invite_options(options)
      return valid_user(options[:login])
    end
  end

  def valid_user(login)
    @people = User.find_by(:login => login)

    if @people != current_user
      @error_messages = "你不是邀请的对象"
      render_error
    end
    return true
  end

  def valid_invite_options(options)
    @shop = Shop.find_by(:name => options[:shop_name])
    now = validate_auth_string(options[:auth])
    current_ability(current_user)
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
