#encoding: utf-8
class Admins::Shops::EmployeesController < Admins::Shops::SectionController

  def index
    @employees = current_shop.employees
    @resources = Permission.group(:resource)
  end

  #邀请
  def invite
    @user = User.find_by(:login => params[:login])

    respond_to do |format|
      if @user
        if current_shop.is_employees?(@user)
          format.json{ render :json => {message: "对方已经加入该商店!"}, :status => 403 }
        else
          @user.notify("/employees/invite",
                     "商店 #{current_shop.name} 邀请你加入",
                      :avatar => @user.icon,
                      :url => notification_url(@user.login))
          format.json{ render :json => {message: "已经发送信息给对方了，等待同意！"} }
        end
      else
        # 如果email发送信息给它
        if params[:login] =~ email_match
          UserMailer.invite_employee(params[:login], current_user,
            current_shop, email_invite_url(email_callback_url)).deliver
          format.json{ render :json => {message: "已经发送邀请邮件给对方了，等待同意！"} }
        else
          format.json{ render :json => {message: "用户不存在！"}, :status => 403 }
        end
      end
    end
  end

  def destroy
    employee = current_shop.find_employee(params[:user_id])
    respond_to do | formatat |
      if employee
        employee.destroy
        employee.user.notify("/shops/leaved",
                        "你已经离开#{current_shop.name} 商店",
                       {:avatar => current_shop.photos.icon,
                        :url => "/shops/#{current_shop.name}"})
        formatat.json{ render :json => {} }
      else
        formatat.json{ render :json => {message: "商店不存在该用户！"}, :status => 403 }
      end
    end
  end

  def find_by_group
    @employees = current_shop.groups.find_by(:id => params[:group_id]).users

    respond_to do |formatat|
      formatat.json{ render :json => @employees.as_json(root: false, methods: :icon) }
      formatat.html
    end
  end

  #雇员入加权限组
  def group_join_employee
    employee = current_shop.find_employee(params[:shop_user_id])
    group = current_shop.groups.find_by(id: params[:shop_group_id])

    return unless valid_employee_group(employee, group)

    unless group.shop_user_groups.find_by(:shop_user_id => employee.id).nil?
      respond_block({message: "该组别已经有这个雇员了!" }, 403)
      return
    end
    user_group = group.create_user(params[:shop_user_id])
    unless user_group.valid?
      respond_block({message: "加入雇员失败！" }, 403)
      return
    end
    respond_block(user_group.user.as_json(root: false, methods: :icon), 200)
  end

  #删除雇员在权限组
  def group_remove_employee
    employee = current_shop.find_employee(params[:shop_user_id])
    group = current_shop.groups.find_by(id: params[:shop_group_id])

    return unless valid_employee_group(employee, group)

    if group.shop_user_groups.find_by(:shop_user_id => employee.id).nil?
      respond_block({message: "该组别没有这个雇员了!" }, 403)
      return
    end
    group.remove_user(params[:shop_user_id])
    respond_block({}, 200)
  end

  private
  def notification_url(login)
    "/people/#{encrypt(current_shop.name)}/show_invite/#{encrypt(login)}?auth=#{generate_auth_string}"
  end

  def email_callback_url
    "/people/#{encrypt(current_shop.name)}/show_email_invite?auth=#{generate_auth_string}"
  end

  def email_invite_url(url)
    "#{accounts_provider_url}/accounts/login?redirect_uri=http://#{request.env['HTTP_HOST']}#{url}"
  end

  def email_match
    /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  end

  def encrypt(val)
    Crypto.encrypt(val)
  end

  def valid_employee_group(employee, group)
    if employee.nil?
      respond_block({message: "商店不存在雇员信息！"}, 403)
      return false
    end

    if group.nil?
      respond_block({message: "商店不存权限组!" }, 403)
      return false
    end
    return true
  end

  def respond_block(_json, _status)
    respond_to do |formatat|
      formatat.json{ render json: _json, status: _status }
    end
  end
end