ActiveAdmin.register UserChecking do
  scope :waiting_audit, default: true do
    UserChecking.where("shop_name <> '' and rejected = ? and checked = ?", false, false)
  end

  scope :rejected do
    UserChecking.where("rejected = ? and checked <> ?", true, true)
  end

  scope :checked do
    UserChecking.where("checked = ?", true)
  end

  actions :index, :show

  index do
    column :user
    column :shop_name
    column :ower_name
    column :ower_shenfenzheng_number
    default_actions
  end

  show do
    render "check_info"
  end

  member_action :check, method: :post do
    user_checking = UserChecking.find(params[:id])
    user_checking.update_attributes(checked: true)

    user = user_checking.user
    user.services << Service.where(service_type: user_checking.service.service_type)
    user_checking.send_checked_mail

    redirect_to action: :index
  end

  member_action :reject, method: :post do
    user_checking = UserChecking.find(params[:id])
    user_checking.update_attributes(rejected: true, rejected_reason: params[:reject_reason])
    user_checking.update_rejected_times
    user_checking.send_rejected_mail

    redirect_to action: :index
  end
end