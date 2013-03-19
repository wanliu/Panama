#encoding: utf-8
class PeopleController < ApplicationController
  before_filter :login_required, :only => [
    :show_invite,
    :agree_invite_user,
    :agree_email_invite_user,
    :show_email_invite]

  layout "people"

  def show
    @people = User.find_by(:login => params[:id])
  end

  def show_invite
    valid_invite_user
  end

  def agree_invite_user
    if valid_invite_user
      shop_user = @shop.shop_users.create(:user_id => current_user.id)
      respond_to do | format |
        if shop_user.valid?
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

  private
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
        @error_messages = "出错了!你不是邀请的对象"
        render template: "errors/errors_403", status: 403, layout: "error"
        return false
      end
      return true
  end

  def valid_invite_options(options)
    @shop = Shop.find_by(:name => options[:shop_name])
    now = validate_auth_string(options[:auth])

    @error_messages = if !now
      "无效的邀请信息"
    elsif now+3.day < DateTime.now
      "邀请信息已经过期！"
    elsif @shop.nil?
      "商店不存在"
    end
    if @error_messages
      render template: "errors/errors_403", status: 403, layout: "error"
      return false
    end
    return true
  end
end
