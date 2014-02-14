#encoding: utf-8

ActiveAdmin.register UserChecking do
  scope :等待审核, default: true do
    UserChecking.joins(:user).where("rejected = ? and checked = ? and users.services <> ?", false, false, '')
  end

  scope :被驳回 do
    UserChecking.where("rejected = ? and checked <> ?", true, true)
  end

  scope :已审核通过 do
    UserChecking.where("checked = ?", true)
  end

  actions :index, :show

  index do
    column :user
    column :service
    column :ower_name
    column :ower_shenfenzheng_number
    default_actions
  end

  show do
    render "check_info"
  end

  member_action :check, method: :post do
    user_checking = UserChecking.find(params[:id])
    shop = user_checking.user.try(:shop)
    if !shop.blank?
      shop_url = "/shops/" + shop.name
      shop.transaction do
        unless user_checking.update_attributes(:checked => true, :rejected => false) &&
          shop.update_attributes(:shop_url => shop_url, :audit_count => shop.audit_count + 1) &&
          shop.active
          raise ActiveRecord::Rollback
        end
      end
      shop.reload
      shop.configure_shop
    else
      user_checking.update_attributes(:checked => true, :rejected => false)
    end
    user_checking.send_checked_mail if shop.try(:actived?)

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